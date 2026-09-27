import Foundation
import SwiftData

@Model
final class SavedStation {
    var stationID: String
    var latitude: Double
    var longitude: Double
    var savedAt: Date

    init(
        stationID: String,
        latitude: Double,
        longitude: Double,
        savedAt: Date = .now
    ) {
        self.stationID = stationID
        self.latitude = latitude
        self.longitude = longitude
        self.savedAt = savedAt
    }
}

extension SavedStation {
    convenience init(_ location: SavedLocation, savedAt: Date = .now) {
        self.init(
            stationID: location.stationID,
            latitude: location.latitude,
            longitude: location.longitude,
            savedAt: savedAt
        )
    }

    static var current: FetchDescriptor<SavedStation> {
        var descriptor = FetchDescriptor<SavedStation>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }
}

@Model
final class RecentJourney {
    #Unique<RecentJourney>([\.originID, \.destinationID])
    #Index<RecentJourney>([\.lastSearchedAt])

    var originID: String
    var destinationID: String
    var lastSearchedAt: Date

    init(originID: String, destinationID: String, lastSearchedAt: Date = .now) {
        self.originID = originID
        self.destinationID = destinationID
        self.lastSearchedAt = lastSearchedAt
    }
}
