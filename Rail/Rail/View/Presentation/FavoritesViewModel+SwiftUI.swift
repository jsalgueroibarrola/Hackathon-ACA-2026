import SwiftUI

extension FavoritesViewModel {
    func binding(for stationID: String, isFavorite: Bool) -> Binding<Bool> {
        Binding {
            isFavorite
        } set: { newValue in
            self.setFavorite(newValue, stationID: stationID)
        }
    }

    func move(_ stationIDs: [String], fromOffsets source: IndexSet, toOffset destination: Int) {
        var reordered = stationIDs
        reordered.move(fromOffsets: source, toOffset: destination)
        reorder(reordered)
    }
}
