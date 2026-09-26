import Foundation
import SwiftData

@Model
final class ServiceAlertFeed {
    var etag: String?
    var feedTimestamp: Date?
    var fetchedAt: Date
    var expiresAt: Date
    var isStale: Bool

    @Relationship(deleteRule: .cascade, inverse: \ServiceAlert.feed)
    var alerts: [ServiceAlert]

    init(
        etag: String?,
        feedTimestamp: Date?,
        fetchedAt: Date,
        expiresAt: Date,
        isStale: Bool
    ) {
        self.etag = etag
        self.feedTimestamp = feedTimestamp
        self.fetchedAt = fetchedAt
        self.expiresAt = expiresAt
        self.isStale = isStale
        self.alerts = []
    }
}
