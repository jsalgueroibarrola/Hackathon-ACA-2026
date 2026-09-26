import Foundation
import SwiftData

@Model
final class RealtimeFeed {
    var etag: String?
    var feedTimestamp: Date?
    var isPartial: Bool
    var fetchedAt: Date
    var expiresAt: Date
    var isStale: Bool

    @Relationship(deleteRule: .cascade, inverse: \LiveTrain.feed)
    var trains: [LiveTrain]

    init(
        etag: String?,
        feedTimestamp: Date?,
        isPartial: Bool,
        fetchedAt: Date,
        expiresAt: Date,
        isStale: Bool
    ) {
        self.etag = etag
        self.feedTimestamp = feedTimestamp
        self.isPartial = isPartial
        self.fetchedAt = fetchedAt
        self.expiresAt = expiresAt
        self.isStale = isStale
        self.trains = []
    }
}
