import SwiftData
import SwiftUI

struct FavoriteStationsView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query(sort: FavoriteStation.order) private var favorites: [FavoriteStation]
    @Query(sort: \Station.name) private var stations: [Station]

    private var items: [StationRowItem] {
        StationRowItemBuilder.items(
            for: favorites.map(\.stationID),
            among: stations,
            location: location.location
        )
    }

    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(value: HomeRoute.station(id: item.id)) {
                    StationRow(item, showsSeparator: false)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.bgPrimary)
            }
            .onDelete { offsets in
                favoritesModel.remove(offsets.map { items[$0].id })
            }
            .onMove { source, destination in
                favoritesModel.reorder(
                    HomeRoute.reordered(items.map(\.id), from: source, to: destination)
                )
            }
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .scrollContentBackground(.hidden)
        .background(.bgSecondary)
        .overlay {
            if items.isEmpty {
                ContentUnavailableView(
                    Self.emptyTitle,
                    systemImage: "star",
                    description: Text(Self.emptyMessage)
                )
            }
        }
        .toolbar {
            if !items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .navigationTitle(Self.title)
    }

    private static let title = LocalizedStringResource(
        "Estaciones favoritas",
        comment: "Cabecera de la sección de favoritas en Inicio y título de la pantalla con todas las favoritas."
    )

    private static let emptyTitle = LocalizedStringResource(
        "Sin estaciones favoritas",
        comment: "Pantalla de favoritas: título cuando no queda ninguna estación favorita."
    )

    private static let emptyMessage = LocalizedStringResource(
        "Toca la estrella de cualquier estación para añadirla aquí.",
        comment: "Pantalla de favoritas: explica cómo añadir estaciones cuando la lista está vacía."
    )
}

#if DEBUG
#Preview("Con favoritas", traits: .favoriteStationsSampleData) {
    NavigationStack {
        FavoriteStationsView()
    }
    .environment(LocationViewModel.preview())
}

#Preview("Vacía", traits: .nextTrainsSampleData) {
    NavigationStack {
        FavoriteStationsView()
    }
    .environment(LocationViewModel.preview())
}

#Preview("Modo oscuro", traits: .favoriteStationsSampleData) {
    NavigationStack {
        FavoriteStationsView()
    }
    .environment(LocationViewModel.preview(authorization: .denied))
    .preferredColorScheme(.dark)
}
#endif
