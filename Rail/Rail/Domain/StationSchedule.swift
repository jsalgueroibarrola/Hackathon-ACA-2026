import Foundation

struct StationDeparture: Identifiable, Hashable, Sendable {
    let id: String
    let train: String
    let date: Date
}

struct StationLineSchedule: Identifiable, Hashable, Sendable {
    let lineID: String
    let lineName: String
    let colorHex: String
    let direction: TripDirection
    let destination: String
    let departures: [StationDeparture]

    var id: String { "\(lineID)-\(direction.rawValue)" }

    func upcoming(from date: Date) -> [StationDeparture] {
        Array(departures.drop { $0.date < date })
    }

    func replacingDepartures(_ departures: [StationDeparture]) -> StationLineSchedule {
        StationLineSchedule(
            lineID: lineID,
            lineName: lineName,
            colorHex: colorHex,
            direction: direction,
            destination: destination,
            departures: departures
        )
    }
}

struct StationScheduleSource {
    struct Key: Hashable {
        let lineID: String
        let direction: TripDirection
    }

    let station: Station
    let timetable: Timetable
    let calendar: Calendar
    let trips: [Key: [Trip]]
}

enum StationScheduleBuilder {
    static func departures(from source: StationScheduleSource, on day: Date) -> [StationLineSchedule] {
        let midnight = source.calendar.startOfDay(for: day)
        let serviceDays = [source.calendar.date(byAdding: .day, value: -1, to: midnight), midnight].compactMap(\.self)

        return Dictionary(
            grouping: serviceDays.flatMap { schedules(from: source, day: $0) },
            by: \.id
        )
        .values
        .compactMap { group in
            group.first.map {
                $0.replacingDepartures(
                    group.flatMap(\.departures)
                        .filter { $0.date >= midnight }
                        .sorted { $0.date < $1.date }
                )
            }
        }
        .filter { !$0.departures.isEmpty }
        .sorted { ($0.lineID, $0.direction.rawValue) < ($1.lineID, $1.direction.rawValue) }
    }

    static func schedules(from source: StationScheduleSource, day: Date) -> [StationLineSchedule] {
        guard let dayOffset = source.timetable.dayOffset(for: day, calendar: source.calendar) else { return [] }
        let midnight = source.calendar.startOfDay(for: day)

        return source.station.stops
            .compactMap { stop in stop.line.map { (stop: stop, line: $0) } }
            .sorted { $0.line.id < $1.line.id }
            .flatMap { pair in
                TripDirection.allCases.compactMap { direction in
                    schedule(
                        line: pair.line,
                        stop: pair.stop,
                        direction: direction,
                        trips: source.trips[StationScheduleSource.Key(lineID: pair.line.id, direction: direction)] ?? [],
                        dayOffset: dayOffset,
                        midnight: midnight,
                        calendar: source.calendar
                    )
                }
            }
    }

    private static func schedule(
        line: Line,
        stop: LineStop,
        direction: TripDirection,
        trips: [Trip],
        dayOffset: Int,
        midnight: Date,
        calendar: Calendar
    ) -> StationLineSchedule? {
        let stops = line.orderedStops(for: direction)
        guard let destination = stops.last?.station, destination.id != stop.stationID else { return nil }

        let departures = trips
            .filter { $0.runs(onDayOffset: dayOffset) }
            .compactMap { trip in
                trip.minute(atStopSequence: stop.sequence, stopCount: stops.count)
                    .flatMap { calendar.date(byAdding: .minute, value: $0, to: midnight) }
                    .map { StationDeparture(id: "\(trip.id)-\(dayOffset)", train: trip.train, date: $0) }
            }
            .sorted { $0.date < $1.date }

        return departures.isEmpty
            ? nil
            : StationLineSchedule(
                lineID: line.id,
                lineName: line.name,
                colorHex: line.colorHex,
                direction: direction,
                destination: destination.name,
                departures: departures
            )
    }
}
