import Foundation

struct NextTrainsSchedules: Hashable, Sendable {
    let stationID: String
    let timeZone: TimeZone
    let today: [StationLineSchedule]
    let tomorrow: [StationLineSchedule]
}

enum NextTrainsScheduleBuilder {
    static func schedules(from source: StationScheduleSource, day: Date) -> NextTrainsSchedules {
        NextTrainsSchedules(
            stationID: source.station.id,
            timeZone: source.calendar.timeZone,
            today: StationScheduleBuilder.departures(from: source, on: day),
            tomorrow: source.calendar.date(byAdding: .day, value: 1, to: day)
                .map { StationScheduleBuilder.schedules(from: source, day: $0) } ?? []
        )
    }
}
