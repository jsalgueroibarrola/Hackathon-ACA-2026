import Foundation

@MainActor
protocol UserStationsRepository {
    func addFavorite(stationID: String) throws
    func removeFavorites(stationIDs: [String]) throws
    func reorderFavorites(stationIDs: [String]) throws
    func saveStation(_ location: SavedLocation) throws
    func clearSavedStation() throws
}

#if DEBUG
struct PreviewUserStationsRepository: UserStationsRepository {
    func addFavorite(stationID: String) throws {}
    func removeFavorites(stationIDs: [String]) throws {}
    func reorderFavorites(stationIDs: [String]) throws {}
    func saveStation(_ location: SavedLocation) throws {}
    func clearSavedStation() throws {}
}
#endif
