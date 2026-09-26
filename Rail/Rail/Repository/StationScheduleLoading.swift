import Foundation
import SwiftData

extension ModelContext {
    func scheduleSource(
        for station: Station,
        timetable: Timetable,
        calendar: Calendar
    ) throws -> StationScheduleSource {
        let lineIDs = station.stops.map(\.lineID)
        let trips = try fetch(
            FetchDescriptor<Trip>(predicate: #Predicate { lineIDs.contains($0.lineID) })
        )

        return StationScheduleSource(
            station: station,
            timetable: timetable,
            calendar: calendar,
            trips: Dictionary(grouping: trips) {
                StationScheduleSource.Key(lineID: $0.lineID, direction: $0.direction)
            }
        )
    }
}
