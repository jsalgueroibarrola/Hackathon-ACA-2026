import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class FavoritesViewModel {
    private let repository: any UserStationsRepository

    init(repository: any UserStationsRepository) {
        self.repository = repository
    }

    func setFavorite(_ isFavorite: Bool, stationID: String) {
        attempt {
            if isFavorite {
                try repository.addFavorite(stationID: stationID)
            } else {
                try repository.removeFavorites(stationIDs: [stationID])
            }
        }
    }

    func remove(_ stationIDs: [String]) {
        attempt { try repository.removeFavorites(stationIDs: stationIDs) }
    }

    func reorder(_ stationIDs: [String]) {
        attempt { try repository.reorderFavorites(stationIDs: stationIDs) }
    }

    private func attempt(_ operation: () throws -> Void) {
        do {
            try operation()
            WidgetReloader.reloadNextTrains()
        } catch {
            Logger.userStations.error(
                "Favorites update failed: \(String(describing: error), privacy: .public)"
            )
        }
    }
}

#if DEBUG
extension FavoritesViewModel {
    static func preview(
        repository: any UserStationsRepository = PreviewUserStationsRepository()
    ) -> FavoritesViewModel {
        FavoritesViewModel(repository: repository)
    }
}
#endif
