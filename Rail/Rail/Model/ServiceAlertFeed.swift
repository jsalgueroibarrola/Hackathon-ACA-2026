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

extension ServiceAlertFeed {
    func isExpired(at date: Date) -> Bool {
        date >= expiresAt
    }

    var orderedAlerts: [ServiceAlert] {
        alerts.sorted { $0.position < $1.position }
    }
}
