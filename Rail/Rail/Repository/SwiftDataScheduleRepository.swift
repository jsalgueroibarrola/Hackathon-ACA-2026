import Foundation
import SwiftData

@ModelActor
actor SwiftDataScheduleRepository: ScheduleRepository {
    func nextTrains(for request: ScheduleRequest) async throws -> NextTrainsSchedules? {
        try source(stationID: request.stationID).map {
            NextTrainsScheduleBuilder.schedules(from: $0, day: request.serviceDay)
        }
    }

    func schedules(for request: ScheduleRequest) async throws -> [StationLineSchedule] {
        try source(stationID: request.stationID).map {
            StationScheduleBuilder.schedules(from: $0, day: request.serviceDay)
        } ?? []
    }

    func journeys(for request: JourneyRequest) async throws -> [Journey] {
        guard
            let network = try modelContext.first(TransitNetwork.self),
            let timetable = try modelContext.first(Timetable.self)
        else { return [] }

        return JourneyBuilder.journeys(
            from: try modelContext.journeySource(
                connecting: [request.originID, request.destinationID],
                timetable: timetable,
                calendar: network.calendar
            ),
            originID: request.originID,
            destinationID: request.destinationID,
            day: request.serviceDay
        )
    }

    private func source(stationID: String) throws -> StationScheduleSource? {
        var stationDescriptor = FetchDescriptor<Station>(predicate: #Predicate { $0.id == stationID })
        stationDescriptor.fetchLimit = 1

        guard
            let network = try modelContext.first(TransitNetwork.self),
            let timetable = try modelContext.first(Timetable.self),
            let station = try modelContext.fetch(stationDescriptor).first
        else { return nil }

        return try modelContext.scheduleSource(
            for: station,
            timetable: timetable,
            calendar: network.calendar
        )
    }
}
