import SwiftData
import SwiftUI

struct FavoriteStationsSection: View {
    let onNavigate: (AppRoute) -> Void

    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query(sort: FavoriteStation.order) private var favorites: [FavoriteStation]
    @Query(sort: \Station.name) private var stations: [Station]
    @State private var isAddingStation = false

    private var items: [StationRowItem] {
        StationRowItemBuilder.items(
            for: favorites.map(\.stationID),
            among: stations,
            location: location.location
        )
    }

    var body: some View {
        FavoriteStationsContainer(items, onAction: handle)
            .sheet(isPresented: $isAddingStation) {
                StationPickerSheet(selection: Set(favorites.map(\.stationID))) { stationID in
                    favoritesModel.setFavorite(true, stationID: stationID)
                }
            }
    }

    private func handle(_ action: FavoriteStationsAction) {
        switch action {
        case .open(let stationID):
            onNavigate(.station(id: stationID))
        case .showAll:
            onNavigate(.favorites)
        case .remove(let stationID):
            favoritesModel.remove([stationID])
        case .addStation:
            isAddingStation = true
        }
    }
}

#if DEBUG
private struct FavoriteStationsSectionPreview: View {
    var body: some View {
        ScrollView {
            FavoriteStationsSection(onNavigate: { _ in })
                .fitsScrollViewport()
        }
        .background(.bgSecondary)
    }
}

#Preview("Con favoritas", traits: .favoriteStationsSampleData) {
    FavoriteStationsSectionPreview()
        .environment(LocationViewModel.preview(location: .alameda))
}

#Preview("Sin ubicación", traits: .favoriteStationsSampleData) {
    FavoriteStationsSectionPreview()
        .environment(LocationViewModel.preview(authorization: .denied))
}

#Preview("Vacío", traits: .nextTrainsSampleData) {
    FavoriteStationsSectionPreview()
        .environment(LocationViewModel.preview(location: .alameda))
}
#endif
