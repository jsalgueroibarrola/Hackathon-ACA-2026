import Foundation

struct ScheduleRequest: Hashable, Sendable {
    let stationID: String
    let timetableKey: String
    let serviceDay: Date
}

extension ScheduleRequest {
    init?(stationID: String?, timetable: Timetable?, serviceDay: Date?) {
        guard let stationID, let timetable, let serviceDay else { return nil }
        self.init(
            stationID: stationID,
            timetableKey: timetable.etag ?? timetable.version,
            serviceDay: serviceDay
        )
    }

    init?(stationID: String?, timetable: Timetable?, network: TransitNetwork?, at date: Date) {
        self.init(
            stationID: stationID,
            timetable: timetable,
            serviceDay: network?.calendar.startOfDay(for: date)
        )
    }
}

struct JourneyRequest: Hashable, Sendable {
    let originID: String
    let destinationID: String
    let timetableKey: String
    let serviceDay: Date
}

extension JourneyRequest {
    init?(originID: String, destinationID: String, timetable: Timetable?, serviceDay: Date?) {
        guard originID != destinationID, let timetable, let serviceDay else { return nil }
        self.init(
            originID: originID,
            destinationID: destinationID,
            timetableKey: timetable.etag ?? timetable.version,
            serviceDay: serviceDay
        )
    }
}

protocol ScheduleRepository: Sendable {
    func nextTrains(for request: ScheduleRequest) async throws -> NextTrainsSchedules?
    func schedules(for request: ScheduleRequest) async throws -> [StationLineSchedule]
    func journeys(for request: JourneyRequest) async throws -> [Journey]
}

struct DisabledScheduleRepository: ScheduleRepository {
    func nextTrains(for request: ScheduleRequest) async throws -> NextTrainsSchedules? {
        nil
    }

    func schedules(for request: ScheduleRequest) async throws -> [StationLineSchedule] {
        []
    }

    func journeys(for request: JourneyRequest) async throws -> [Journey] {
        []
    }
}
