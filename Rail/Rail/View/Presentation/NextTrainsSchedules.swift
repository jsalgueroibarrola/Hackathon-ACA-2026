import Foundation
import SwiftData

struct NextTrainsSchedules: Hashable, Sendable {
    let stationID: String
    let today: [StationLineSchedule]
    let tomorrow: [StationLineSchedule]
}

enum NextTrainsScheduleBuilder {
    static func schedules(
        for station: Station,
        timetable: Timetable,
        day: Date,
        calendar: Calendar,
        context: ModelContext
    ) -> NextTrainsSchedules {
        NextTrainsSchedules(
            stationID: station.id,
            today: StationScheduleBuilder.schedules(
                for: station,
                timetable: timetable,
                day: day,
                calendar: calendar,
                context: context
            ),
            tomorrow: calendar.date(byAdding: .day, value: 1, to: day)
                .map {
                    StationScheduleBuilder.schedules(
                        for: station,
                        timetable: timetable,
                        day: $0,
                        calendar: calendar,
                        context: context
                    )
                } ?? []
        )
    }
}
