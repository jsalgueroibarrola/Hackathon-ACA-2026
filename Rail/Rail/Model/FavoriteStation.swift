import Foundation
import SwiftData

@Model
final class FavoriteStation {
    #Unique<FavoriteStation>([\.stationID])

    var stationID: String
    var sortOrder: Int
    var addedAt: Date

    init(stationID: String, sortOrder: Int, addedAt: Date = .now) {
        self.stationID = stationID
        self.sortOrder = sortOrder
        self.addedAt = addedAt
    }
}

extension FavoriteStation {
    static var order: [SortDescriptor<FavoriteStation>] {
        [SortDescriptor(\.sortOrder), SortDescriptor(\.addedAt)]
    }
}
