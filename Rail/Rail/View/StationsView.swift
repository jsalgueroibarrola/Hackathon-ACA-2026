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
    @State private var scrollPosition = ScrollPosition(edge: .top)

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
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    if !isFiltering {
                        nearbySection(favoriteIDs: favoriteIDs)
                    }
                    ForEach(sections) { section in
                        anchor(.line(section.lineID))
                        Section {
                            card {
                                rows(section.items, favoriteIDs: favoriteIDs)
                            }
                        } header: {
                            header(
                                section.title,
                                symbol: "circle.fill",
                                tint: lineColor(section.lineID),
                                anchor: .line(section.lineID)
                            )
                        }
                    }
                }
            }
            .scrollPosition($scrollPosition)
            .background(.bgSecondary)
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
        let items = nearby.map {
            StationRowItemBuilder.item(
                for: $0.station,
                location: location.location
            )
        }
        if location.canRequestAccess {
            nearbySection { locationPrompt }
        } else if location.hasLocationFailed {
            nearbySection { locationUnavailable }
        } else if location.isLocating {
            nearbySection { locating }
        } else if isFarFromNetwork {
            nearbySection { farFromNetwork }
        } else if !items.isEmpty {
            nearbySection { rows(items, favoriteIDs: favoriteIDs) }
        }
    }

    @ViewBuilder
    private func nearbySection(@ViewBuilder content: () -> some View)
        -> some View
    {
        anchor(.nearby)
        Section {
            card { content() }
        } header: {
            header(
                Self.nearbyTitle,
                symbol: "location.fill",
                tint: .brandPrimary,
                anchor: .nearby
            )
        }
    }

    private func anchor(_ id: SectionAnchor) -> some View {
        Color.clear
            .frame(height: 0)
            .id(id)
    }

    private func header(
        _ title: LocalizedStringResource,
        symbol: String,
        tint: Color,
        anchor: SectionAnchor
    ) -> some View {
        HStack {
            Button {
                withAnimation {
                    scrollPosition.scrollTo(id: anchor, anchor: .top)
                }
            } label: {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: symbol)
                        .foregroundStyle(tint)
                        .imageScale(.small)
                }
            }
            .buttonStyle(.railGlass(.clear))
            .controlSize(.small)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHint(Self.scrollToSectionHint)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.sm)
    }

    private func lineColor(_ lineID: String) -> Color {
        lines.first { $0.id == lineID }?.tint.base ?? .textTertiary
    }

    private func card(@ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 0) { content() }
            .background(
                .bgPrimary,
                in: .rect(cornerRadius: Radius.md, style: .continuous)
            )
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.bottom, Spacing.lg)
    }

    private func rows(_ items: [StationRowItem], favoriteIDs: Set<String>)
        -> some View
    {
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
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    private var locationPrompt: some View {
        CardMessage(
            LocalizedStringResource(
                "Activa la ubicación",
                comment:
                    "Estaciones: título de la sección «Cerca de ti» cuando aún no se ha pedido permiso de ubicación."
            ),
            message: LocalizedStringResource(
                "Verás qué estaciones tienes más cerca y a qué distancia están.",
                comment:
                    "Estaciones: explica para qué se pide el permiso de ubicación en la sección «Cerca de ti»."
            ),
            icon: .symbol("location.fill", tint: .brandPrimary),
            prominence: .compact,
            primary: CardMessage.Action(
                title: LocalizedStringResource(
                    "Permitir ubicación",
                    comment:
                        "Estaciones: botón de la sección «Cerca de ti» que pide el permiso de ubicación."
                ),
                perform: location.requestAccess
            )
        )
        .padding(Spacing.md)
    }

    private var farFromNetwork: some View {
        CardMessage(
            LocalizedStringResource(
                "Estás lejos de Cercanías Málaga",
                comment:
                    "Estaciones: título de la sección «Cerca de ti» cuando ninguna estación está a menos de 10 km del usuario."
            ),
            message: LocalizedStringResource(
                "Cuando te acerques a Málaga, aquí verás las estaciones que tengas más cerca. Mientras tanto, puedes buscar cualquier estación.",
                comment:
                    "Estaciones: mensaje de la sección «Cerca de ti» cuando el usuario está lejos de la red."
            ),
            icon: .symbol("map.fill", tint: .textTertiary),
            prominence: .compact
        )
        .padding(Spacing.md)
    }

    private var locationUnavailable: some View {
        CardMessage(
            LocalizedStringResource(
                "No hemos podido ubicarte",
                comment:
                    "Estaciones: título de la sección «Cerca de ti» cuando el dispositivo no consigue una ubicación."
            ),
            message: LocalizedStringResource(
                "Puede pasar bajo tierra o en interiores. Inténtalo otra vez o busca cualquier estación.",
                comment:
                    "Estaciones: mensaje de la sección «Cerca de ti» cuando el dispositivo no consigue una ubicación."
            ),
            icon: .symbol("exclamationmark.circle.fill", tint: .statusWarning),
            prominence: .compact,
            primary: CardMessage.Action(
                title: LocalizedStringResource(
                    "Reintentar",
                    comment:
                        "Estaciones: botón de la sección «Cerca de ti» que vuelve a intentar obtener la ubicación."
                ),
                perform: location.retry
            )
        )
        .padding(Spacing.md)
    }

    private var locating: some View {
        CardMessage(
            LocalizedStringResource(
                "Buscando tu ubicación…",
                comment:
                    "Estaciones: título de la sección «Cerca de ti» mientras se obtiene la ubicación."
            ),
            icon: .progress,
            prominence: .compact
        )
        .padding(Spacing.md)
    }

    static let title = LocalizedStringResource(
        "Estaciones",
        comment:
            "Título de la pestaña y de la pantalla con el listado de estaciones."
    )

    private static let nearbyTitle = LocalizedStringResource(
        "Cerca de ti",
        comment:
            "Estaciones: cabecera de la sección con las tres estaciones más cercanas a la ubicación del usuario."
    )

    private static let scrollToSectionHint = LocalizedStringResource(
        "Va al principio de esta sección.",
        comment:
            "Estaciones: indicación de VoiceOver al tocar la cabecera de una sección, que desplaza la lista hasta el comienzo de esa sección."
    )

    private static let searchPrompt = LocalizedStringResource(
        "Buscar estación",
        comment: "Estaciones: texto de ayuda del campo de búsqueda."
    )
}

private enum SectionAnchor: Hashable {
    case nearby
    case line(String)
}

#if DEBUG
    #Preview("Con ubicación", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: .alameda))
    }

    #Preview("Sin permiso", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(
                LocationViewModel.preview(authorization: .notDetermined)
            )
    }

    #Preview("Lejos de la red", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(LocationViewModel.preview(location: .madrid))
    }

    #Preview("Sin ubicación", traits: .favoriteStationsSampleData) {
        StationsView()
            .environment(
                LocationViewModel.preview(
                    location: nil,
                    isLocationUnavailable: true
                )
            )
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
