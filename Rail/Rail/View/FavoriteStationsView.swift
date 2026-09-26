import SwiftData
import SwiftUI

struct FavoriteStationsView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query(sort: FavoriteStation.order) private var favorites: [FavoriteStation]
    @Query(sort: \Station.name) private var stations: [Station]
    @State private var isAddingStation = false

    private static let cardInsets = EdgeInsets(
        top: ScreenLayout.gutter / 2,
        leading: ScreenLayout.margin,
        bottom: ScreenLayout.gutter / 2,
        trailing: ScreenLayout.margin
    )

    private var items: [StationRowItem] {
        StationRowItemBuilder.items(
            for: favorites.map(\.stationID),
            among: stations,
            location: location.location
        )
    }

    var body: some View {
        content
            .background(.bgSecondary)
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(Self.addLabel, systemImage: "plus") {
                        isAddingStation = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $isAddingStation) {
                StationPickerSheet(selection: Set(favorites.map(\.stationID))) { stationID in
                    favoritesModel.setFavorite(true, stationID: stationID)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        let items = items
        if items.isEmpty {
            emptyState
        } else {
            list(items)
        }
    }

    private func list(_ items: [StationRowItem]) -> some View {
        List {
            ForEach(items.enumerated(), id: \.element.id) { index, item in
                card(item, at: index, of: items)
            }
            .onMove { source, destination in
                favoritesModel.move(
                    items.map(\.id),
                    fromOffsets: source,
                    toOffset: destination
                )
            }
            footnote
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .scrollContentBackground(.hidden)
        .contentMargins(
            .top,
            Spacing.xxl - Self.cardInsets.top,
            for: .scrollContent
        )
    }

    private func card(
        _ item: StationRowItem,
        at index: Int,
        of items: [StationRowItem]
    ) -> some View {
        NavigationLink(value: HomeRoute.station(id: item.id)) {
            FavoriteStationCard(
                item,
                isFavorite: favoritesModel.binding(
                    for: item.id,
                    isFavorite: true
                )
            )
        }
        .swipeActions(edge: .trailing) {
            Button(
                FavoriteToggleStyle.removeLabel,
                systemImage: "star.slash",
                role: .destructive
            ) {
                favoritesModel.remove([item.id])
            }
        }
        .accessibilityActions {
            if index > items.startIndex {
                Button(Self.moveUpLabel) {
                    move(items, from: index, to: index - 1)
                }
            }
            if index < items.index(before: items.endIndex) {
                Button(Self.moveDownLabel) {
                    move(items, from: index, to: index + 1)
                }
            }
        }
        .listRowInsets(Self.cardInsets)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func move(_ items: [StationRowItem], from index: Int, to target: Int) {
        favoritesModel.move(
            items.map(\.id),
            fromOffsets: [index],
            toOffset: target > index ? target + 1 : target
        )
        AccessibilityNotification.Announcement(
            String(localized: Self.positionAnnouncement(target + 1, of: items.count))
        )
        .post()
    }

    private var footnote: some View {
        Text(Self.footnoteText)
            .font(.footnote)
            .foregroundStyle(.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowInsets(
                EdgeInsets(
                    top: Spacing.md,
                    leading: ScreenLayout.margin,
                    bottom: Spacing.md,
                    trailing: ScreenLayout.margin
                )
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private var emptyState: some View {
        ScrollView {
            IllustratedMessage(
                Self.emptyTitle,
                message: Self.emptyMessage,
                illustration: .noFavorites
            ) {
                Button(Self.emptyAction) {
                    isAddingStation = true
                }
                .buttonStyle(.railGlass(.tinted))
                .controlSize(.small)
            }
            .padding(.horizontal, ScreenLayout.margin)
            .frame(maxHeight: .infinity)
            .fitsScrollViewport()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private static let title = LocalizedStringResource(
        "Favoritos",
        comment: "Título de la pantalla con todas las estaciones favoritas."
    )

    private static let addLabel = LocalizedStringResource(
        "Añadir estación favorita",
        comment:
            "Favoritos: botón «+» de la barra superior que abre el selector de estación; VoiceOver lo lee."
    )

    private static let emptyTitle = LocalizedStringResource(
        "¡Vaya! Parece que aún no tienes estaciones favoritas…",
        comment:
            "Favoritos: título cuando todavía no hay ninguna estación favorita."
    )

    private static let emptyMessage = LocalizedStringResource(
        "Toca la estrella de cualquier estación y la tendrás siempre a mano.",
        comment:
            "Favoritos: explica cómo añadir estaciones cuando todavía no hay ninguna favorita."
    )

    private static let moveUpLabel = LocalizedStringResource(
        "Subir",
        comment:
            "Favoritos: acción de VoiceOver que sube una estación favorita un puesto en la lista."
    )

    private static let moveDownLabel = LocalizedStringResource(
        "Bajar",
        comment:
            "Favoritos: acción de VoiceOver que baja una estación favorita un puesto en la lista."
    )

    private static func positionAnnouncement(_ position: Int, of count: Int) -> LocalizedStringResource {
        LocalizedStringResource(
            "Posición \(position) de \(count)",
            comment:
                "Favoritos: VoiceOver lo anuncia tras subir o bajar una favorita, por ejemplo «Posición 2 de 5»."
        )
    }

    private static let footnoteText = LocalizedStringResource(
        "Tus primeras favoritas aparecen en Inicio. Mantén pulsada una para cambiar el orden.",
        comment:
            "Favoritos: nota al pie de la lista que explica dónde se usan las favoritas y cómo reordenarlas."
    )

    private static let emptyAction = LocalizedStringResource(
        "Añade una estación",
        comment:
            "Favoritos: botón del estado vacío que abre el selector de estación."
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

    #Preview("Dynamic Type", traits: .favoriteStationsSampleData) {
        NavigationStack {
            FavoriteStationsView()
        }
        .environment(LocationViewModel.preview())
        .dynamicTypeSize(.accessibility2)
    }
#endif
