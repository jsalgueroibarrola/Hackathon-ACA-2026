import Foundation

struct JourneyLeg: Identifiable, Hashable, Sendable {
    let id: String
    let lineID: String
    let colorHex: String
    let train: String
    let headsign: String
    let originName: String
    let destinationName: String
    let departure: Date
    let arrival: Date
}

struct Journey: Identifiable, Hashable, Sendable {
    let first: JourneyLeg
    let connection: JourneyLeg?

    var id: String { [first.id, connection?.id].compactMap(\.self).joined(separator: "|") }

    var legs: [JourneyLeg] { [first] + [connection].compactMap(\.self) }

    var departure: Date { first.departure }

    var arrival: Date { (connection ?? first).arrival }

    var transferStation: String? { connection.map { _ in first.destinationName } }

    var transferMinutes: Int? {
        connection.map { Int($0.departure.timeIntervalSince(first.arrival) / 60) }
    }

    var durationMinutes: Int { Int(arrival.timeIntervalSince(departure) / 60) }
}

struct JourneyLineRoute: Hashable, Sendable {
    let id: String
    let colorHex: String
    let stationIDs: [String]
}

struct JourneySource {
    let lines: [JourneyLineRoute]
    let stationNames: [String: String]
    let timetable: Timetable
    let calendar: Calendar
    let trips: [StationScheduleSource.Key: [Trip]]
}

enum JourneyBuilder {
    static let minimumTransferMinutes = 3

    static func journeys(
        from source: JourneySource,
        originID: String,
        destinationID: String,
        day: Date
    ) -> [Journey] {
        guard originID != destinationID,
              let dayOffset = source.timetable.dayOffset(for: day, calendar: source.calendar)
        else { return [] }
        let context = Context(source: source, dayOffset: dayOffset, midnight: source.calendar.startOfDay(for: day))
        let isDirect = source.lines.contains {
            $0.stationIDs.contains(originID) && $0.stationIDs.contains(destinationID)
        }
        let journeys = isDirect
            ? source.lines.flatMap { legs(on: $0, from: originID, to: destinationID, in: context) }
                .map { Journey(first: $0, connection: nil) }
            : transfers(from: originID, to: destinationID, in: context)
        return journeys.sorted { ($0.departure, $0.arrival) < ($1.departure, $1.arrival) }
    }

    private struct Context {
        let source: JourneySource
        let dayOffset: Int
        let midnight: Date

        func date(_ minute: Int) -> Date? {
            source.calendar.date(byAdding: .minute, value: minute, to: midnight)
        }

        func name(_ stationID: String?) -> String {
            stationID.flatMap { source.stationNames[$0] } ?? ""
        }
    }

    private static func legs(
        on line: JourneyLineRoute,
        from originID: String,
        to destinationID: String,
        in context: Context
    ) -> [JourneyLeg] {
        guard let start = line.stationIDs.firstIndex(of: originID),
              let end = line.stationIDs.firstIndex(of: destinationID),
              start != end
        else { return [] }
        let direction: TripDirection = start < end ? .outbound : .inbound
        let stopCount = line.stationIDs.count
        let headsign = context.name(direction == .outbound ? line.stationIDs.last : line.stationIDs.first)

        return (context.source.trips[StationScheduleSource.Key(lineID: line.id, direction: direction)] ?? [])
            .filter { $0.runs(onDayOffset: context.dayOffset) }
            .compactMap { trip in
                guard let departureMinute = trip.minute(atStopSequence: start, stopCount: stopCount),
                      let arrivalMinute = trip.minute(atStopSequence: end, stopCount: stopCount),
                      arrivalMinute >= departureMinute,
                      let departure = context.date(departureMinute),
                      let arrival = context.date(arrivalMinute)
                else { return nil }
                return JourneyLeg(
                    id: "\(trip.id)-\(context.dayOffset)",
                    lineID: line.id,
                    colorHex: line.colorHex,
                    train: trip.train,
                    headsign: headsign,
                    originName: context.name(originID),
                    destinationName: context.name(destinationID),
                    departure: departure,
                    arrival: arrival
                )
            }
    }

    private static func transfers(
        from originID: String,
        to destinationID: String,
        in context: Context
    ) -> [Journey] {
        let lines = context.source.lines
        let candidates = lines.filter { $0.stationIDs.contains(originID) }.flatMap { first in
            lines.filter { $0.id != first.id && $0.stationIDs.contains(destinationID) }.flatMap { last in
                hubs(between: first, and: last, from: originID, excluding: destinationID).flatMap { hub in
                    connect(
                        legs(on: first, from: originID, to: hub, in: context),
                        to: legs(on: last, from: hub, to: destinationID, in: context)
                    )
                }
            }
        }
        return unique(efficient(candidates))
    }

    private static func hubs(
        between first: JourneyLineRoute,
        and last: JourneyLineRoute,
        from originID: String,
        excluding destinationID: String
    ) -> [String] {
        let origin = first.stationIDs.firstIndex(of: originID) ?? 0
        return first.stationIDs.enumerated()
            .filter { last.stationIDs.contains($0.element) && ![originID, destinationID].contains($0.element) }
            .sorted { abs($0.offset - origin) < abs($1.offset - origin) }
            .map(\.element)
    }

    private static func connect(_ arrivals: [JourneyLeg], to departures: [JourneyLeg]) -> [Journey] {
        let onward = departures.sorted { $0.departure < $1.departure }
        return arrivals.compactMap { leg in
            let earliest = leg.arrival.addingTimeInterval(TimeInterval(minimumTransferMinutes * 60))
            return onward.first { $0.departure >= earliest }.map { Journey(first: leg, connection: $0) }
        }
    }

    private static func efficient(_ journeys: [Journey]) -> [Journey] {
        journeys.filter { journey in
            !journeys.contains { other in
                other.departure >= journey.departure
                    && other.arrival <= journey.arrival
                    && (other.departure > journey.departure || other.arrival < journey.arrival)
            }
        }
    }

    private static func unique(_ journeys: [Journey]) -> [Journey] {
        journeys.reduce(into: (seen: Set<[Date]>(), kept: [Journey]())) { result, journey in
            if result.seen.insert([journey.departure, journey.arrival]).inserted {
                result.kept.append(journey)
            }
        }
        .kept
    }
}
