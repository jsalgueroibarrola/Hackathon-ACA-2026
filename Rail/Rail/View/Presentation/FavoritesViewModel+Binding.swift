import SwiftUI

extension FavoritesViewModel {
    func binding(for stationID: String, isFavorite: Bool) -> Binding<Bool> {
        Binding {
            isFavorite
        } set: { newValue in
            self.setFavorite(newValue, stationID: stationID)
        }
    }
}
