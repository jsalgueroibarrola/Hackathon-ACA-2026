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

protocol ScheduleRepository: Sendable {
    func nextTrains(for request: ScheduleRequest) async throws -> NextTrainsSchedules?
    func schedules(for request: ScheduleRequest) async throws -> [StationLineSchedule]
}

struct DisabledScheduleRepository: ScheduleRepository {
    func nextTrains(for request: ScheduleRequest) async throws -> NextTrainsSchedules? {
        nil
    }

    func schedules(for request: ScheduleRequest) async throws -> [StationLineSchedule] {
        []
    }
}
