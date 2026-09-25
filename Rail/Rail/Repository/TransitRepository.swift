import Foundation

protocol TransitRepository: Sendable {
    func localState() async throws -> LocalDataState
    func importNetwork(
        _ dto: NetworkResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws
    func importTimetable(
        _ dto: TimetableResponseDTO,
        etag: String?,
        fetchedAt: Date
    ) async throws
    func markRevalidated(
        network: Bool,
        timetable: Bool,
        fetchedAt: Date
    ) async throws
}
