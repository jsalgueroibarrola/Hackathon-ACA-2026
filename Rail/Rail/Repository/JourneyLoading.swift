import Foundation
import SwiftData

extension ModelContext {
    func journeySource(
        connecting stationIDs: [String],
        timetable: Timetable,
        calendar: Calendar
    ) throws -> JourneySource {
        let lineIDs = Array(
            Set(
                try fetch(
                    FetchDescriptor<LineStop>(predicate: #Predicate { stationIDs.contains($0.stationID) })
                )
                .map(\.lineID)
            )
        )
        let lines = try fetch(
            FetchDescriptor<Line>(predicate: #Predicate { lineIDs.contains($0.id) })
        )
        let trips = try fetch(
            FetchDescriptor<Trip>(predicate: #Predicate { lineIDs.contains($0.lineID) })
        )
        let stops = lines.flatMap(\.orderedStops)

        return JourneySource(
            lines: lines.map { line in
                JourneyLineRoute(
                    id: line.id,
                    colorHex: line.colorHex,
                    stationIDs: line.orderedStops.map(\.stationID)
                )
            },
            stationNames: Dictionary(
                stops.compactMap { stop in stop.station.map { (stop.stationID, $0.name) } },
                uniquingKeysWith: { first, _ in first }
            ),
            timetable: timetable,
            calendar: calendar,
            trips: Dictionary(grouping: trips) {
                StationScheduleSource.Key(lineID: $0.lineID, direction: $0.direction)
            }
        )
    }
}
