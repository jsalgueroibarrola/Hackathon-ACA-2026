import SwiftUI

struct FavoriteToggleRow: View {
    let item: StationRowItem
    let isFavorite: Bool
    let showsSeparator: Bool

    @Environment(FavoritesViewModel.self) private var favoritesModel

    var body: some View {
        StationRow(
            item,
            isFavorite: favoritesModel.binding(for: item.id, isFavorite: isFavorite),
            accessory: .hidden,
            showsSeparator: showsSeparator
        )
    }
}
