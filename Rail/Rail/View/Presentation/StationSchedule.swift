import Foundation
import SwiftData

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
}

enum StationScheduleBuilder {
    static func schedules(
        for station: Station,
        timetable: Timetable,
        day: Date,
        calendar: Calendar,
        context: ModelContext
    ) -> [StationLineSchedule] {
        guard let dayOffset = timetable.dayOffset(for: day, calendar: calendar) else { return [] }
        let midnight = calendar.startOfDay(for: day)

        return station.stops
            .compactMap { stop in stop.line.map { (stop: stop, line: $0) } }
            .sorted { $0.line.id < $1.line.id }
            .flatMap { pair in
                TripDirection.allCases.compactMap { direction in
                    schedule(
                        line: pair.line,
                        stop: pair.stop,
                        direction: direction,
                        dayOffset: dayOffset,
                        midnight: midnight,
                        calendar: calendar,
                        context: context
                    )
                }
            }
    }

    private static func schedule(
        line: Line,
        stop: LineStop,
        direction: TripDirection,
        dayOffset: Int,
        midnight: Date,
        calendar: Calendar,
        context: ModelContext
    ) -> StationLineSchedule? {
        let stops = line.orderedStops(for: direction)
        guard let destination = stops.last?.station, destination.id != stop.stationID else { return nil }

        let lineID = line.id
        let directionRaw = direction.rawValue
        let descriptor = FetchDescriptor<Trip>(
            predicate: #Predicate<Trip> { $0.lineID == lineID && $0.directionRaw == directionRaw },
            sortBy: [SortDescriptor(\.firstDepartureMinute)]
        )

        let departures = ((try? context.fetch(descriptor)) ?? [])
            .filter { $0.runs(onDayOffset: dayOffset) }
            .compactMap { trip in
                trip.minute(atStopSequence: stop.sequence, stopCount: stops.count)
                    .flatMap { calendar.date(byAdding: .minute, value: $0, to: midnight) }
                    .map { StationDeparture(id: trip.id, train: trip.train, date: $0) }
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

extension Date.FormatStyle {
    static func departureTime(in timeZone: TimeZone) -> Date.FormatStyle {
        Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
    }
}
