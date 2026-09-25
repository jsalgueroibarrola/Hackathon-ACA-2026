import Foundation

struct LiveFeedState: Sendable, Equatable {
    var etag: String?
    var expiresAt: Date?

    static let empty = LiveFeedState()
}

protocol LiveFeedRepository: Sendable {
    func state(of feed: LiveFeed) async throws -> LiveFeedState
    func replaceAlerts(
        _ response: ETagged<AlertsResponseDTO>,
        fetchedAt: Date
    ) async throws
    func mergeRealtime(
        _ response: ETagged<RealtimeResponseDTO>,
        fetchedAt: Date
    ) async throws
    func markRevalidated(
        _ feed: LiveFeed,
        freshness: CacheFreshness,
        at date: Date
    ) async throws
}
