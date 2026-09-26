import SwiftData
import SwiftUI

struct StationsView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query private var lines: [Line]
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var favorites: [FavoriteStation]
    @State private var query = ""
    @State private var lineFilter: String?

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isFiltering: Bool {
        !trimmedQuery.isEmpty || lineFilter != nil
    }

    private var favoriteIDs: Set<String> {
        Set(favorites.map(\.stationID))
    }

    private var nearby: [NearbyStation] {
        location.nearest(stations).filter {
            $0.distance <= NextTrainsCardStateBuilder.nearbyRadius
        }
    }

    private var isFarFromNetwork: Bool {
        location.location != nil && !stations.isEmpty && nearby.isEmpty
    }

    private var rowLocation: UserLocation? {
        isFarFromNetwork ? nil : location.location
    }

    private var sections: [StationPickerSection] {
        StationPickerSectionBuilder.sections(
            lines: lines,
            query: query,
            lineFilter: lineFilter,
            location: rowLocation
        )
    }

    var body: some View {
        NavigationStack {
            let sections = sections
            let favoriteIDs = favoriteIDs
            List {
                if !isFiltering {
                    nearbySection(favoriteIDs: favoriteIDs)
                }
                ForEach(sections) { section in
                    Section {
                        rows(section.items, favoriteIDs: favoriteIDs)
                    } header: {
                        StationSectionHeader(section.title)
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(Spacing.md)
            .navigationLinkIndicatorVisibility(.hidden)
            .overlay {
                if sections.isEmpty && !trimmedQuery.isEmpty {
                    StationSearchNoResults(trimmedQuery)
                }
            }
            .safeAreaBar(edge: .top) {
                LineFilterBar(
                    StationPickerSectionBuilder.lineIDs(lines),
                    selection: $lineFilter
                )
            }
            .searchable(text: $query, prompt: Text(Self.searchPrompt))
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .appRouteDestinations()
        }
    }

    @ViewBuilder
    private func nearbySection(favoriteIDs: Set<String>) -> some View {
        if location.canRequestAccess {
            Section {
                locationPrompt
            } header: {
                StationSectionHeader(Self.nearbyTitle)
            }
        } else if location.isLocating {
            Section {
                locating
            } header: {
                StationSectionHeader(Self.nearbyTitle)
            }
        } else if isFarFromNetwork {
            Section {
                farFromNetwork
            } header: {
                StationSectionHeader(Self.nearbyTitle)
            }
        } else {
            let items = nearby.map {
                StationRowItemBuilder.item(for: $0.station, location: location.location)
            }
            if !items.isEmpty {
                Section {
                    rows(items, favoriteIDs: favoriteIDs)
                } header: {
                    StationSectionHeader(Self.nearbyTitle)
                }
            }
        }
    }

    private func rows(_ items: [StationRowItem], favoriteIDs: Set<String>) -> some View {
        ForEach(items) { item in
            NavigationLink(value: AppRoute.station(id: item.id)) {
                StationRow(
                    item,
                    isFavorite: favoritesModel.binding(
                        for: item.id,
                        isFavorite: favoriteIDs.contains(item.id)
                    ),
                    favoriteEdge: .leading,
                    showsSeparator: item.id != items.last?.id
                )
            }
            .listRowInsets(StationRow.listRowInsets)
            .listRowSeparator(.hidden)
        }
    }

    private var locationPrompt: some View {
        CardMessage(
            LocalizedStringResource(
                "Activa la ubicación",
                comment: "Estaciones: título de la sección «Cerca de ti» cuando aún no se ha pedido permiso de ubicación."
            ),
            message: LocalizedStringResource(
                "Verás qué estaciones tienes más cerca y a qué distancia están.",
                comment: "Estaciones: explica para qué se pide el permiso de ubicación en la sección «Cerca de ti»."
            ),
            icon: .symbol("location.fill", tint: .brandPrimary),
            prominence: .compact,
            primary: CardMessage.Action(
                title: LocalizedStringResource(
                    "Permitir ubicación",
                    comment: "Estaciones: botón de la sección «Cerca de ti» que pide el permiso de ubicación."
                ),
                perform: location.requestAccess
            )
        )
        .listRowInsets(StationRow.listRowInsets)
        .listRowSeparator(.hidden)
    }

    private var farFromNetwork: some View {
        CardMessage(
            LocalizedStringResource(
                "Estás lejos de Cercanías Málaga",
                comment: "Estaciones: título de la sección «Cerca de ti» cuando ninguna estación está a menos de 10 km del usuario."
            ),
            message: LocalizedStringResource(
                "Cuando te acerques a Málaga, aquí verás las estaciones que tengas más cerca. Mientras tanto, puedes buscar cualquier estación.",
                comment: "Estaciones: mensaje de la sección «Cerca de ti» cuando el usuario está lejos de la red."
            ),
            icon: .symbol("map.fill", tint: .textTertiary),
            prominence: .compact
        )
        .listRowInsets(StationRow.listRowInsets)
        .listRowSeparator(.hidden)
    }

    private var locating: some View {
        CardMessage(
            LocalizedStringResource(
                "Buscando tu ubicación…",
                comment: "Estaciones: título de la sección «Cerca de ti» mientras se obtiene la ubicación."
            ),
            icon: .progress,
            prominence: .compact
        )
        .listRowInsets(StationRow.listRowInsets)
        .listRowSeparator(.hidden)
    }

    static let title = LocalizedStringResource(
        "Estaciones",
        comment: "Título de la pestaña y de la pantalla con el listado de estaciones."
    )

    private static let nearbyTitle = LocalizedStringResource(
        "Cerca de ti",
        comment: "Estaciones: cabecera de la sección con las tres estaciones más cercanas a la ubicación del usuario."
    )

    private static let searchPrompt = LocalizedStringResource(
        "Buscar estación",
        comment: "Estaciones: texto de ayuda del campo de búsqueda."
    )
}

#if DEBUG
    #Preview("Con ubicación", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: .alameda))
    }

    #Preview("Sin permiso", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(authorization: .notDetermined))
    }

    #Preview("Lejos de la red", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: .madrid))
    }

    #Preview("Buscando", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: nil))
    }

    #Preview("Modo oscuro", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(authorization: .denied))
            .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: .alameda))
            .dynamicTypeSize(.accessibility2)
    }
#endif
