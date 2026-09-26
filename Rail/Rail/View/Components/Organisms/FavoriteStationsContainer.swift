import SwiftUI

enum FavoriteStationsAction: Hashable, Sendable {
    case open(String)
    case showAll
    case remove(String)
    case addStation
}

struct FavoriteStationsContainer: View {
    private let items: [StationRowItem]
    private let onAction: (FavoriteStationsAction) -> Void

    init(
        _ items: [StationRowItem],
        onAction: @escaping (FavoriteStationsAction) -> Void
    ) {
        self.items = items
        self.onAction = onAction
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            header
            content
        }
        .padding(Spacing.lg)
        .animation(.smooth, value: items)
    }

    private var header: some View {
        CardSectionHeader(
            LocalizedStringResource(
                "Estaciones favoritas",
                comment:
                    "Cabecera de la sección de favoritas en Inicio."
            )
        ) {
            if !items.isEmpty {
                showAllButton
            }
        }
    }

    private var showAllButton: some View {
        Button {
            onAction(.showAll)
        } label: {
            HStack(spacing: Spacing.xs) {
                Text(
                    LocalizedStringResource(
                        "Ver más",
                        comment:
                            "Inicio: enlace de la cabecera de favoritas que abre la lista completa."
                    )
                )
                Image(systemName: "chevron.right")
            }
            .font(.footnote)
            .background {
                Color.clear
                    .frame(minWidth: Size.touchMin, minHeight: Size.touchMin)
                    .contentShape(.rect)
            }
        }
        .buttonStyle(.borderless)
        .tint(.brandPrimary)
        .accessibilityLabel(
            LocalizedStringResource(
                "Ver todas las estaciones favoritas",
                comment:
                    "Inicio: etiqueta de VoiceOver del enlace «Ver más» de la sección de favoritas."
            )
        )
    }

    @ViewBuilder
    private var content: some View {
        if items.isEmpty {
            emptyState
        } else {
            ViewThatFits(in: .vertical) {
                ForEach(
                    FavoritesCapacity.candidateCounts(total: items.count),
                    id: \.self,
                    content: cards
                )
            }
        }
    }

    private func cards(_ count: Int) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(items.prefix(count)) { item in
                card(item)
            }
        }
    }

    private func card(_ item: StationRowItem) -> some View {
        Button {
            onAction(.open(item.id))
        } label: {
            FavoriteStationCard(item)
        }
        .buttonStyle(.plain)
        .contentShape(.contextMenuPreview, FavoriteStationCard.shape)
        .contextMenu {
            Button(
                FavoriteToggleStyle.removeLabel,
                systemImage: "star.slash",
                role: .destructive
            ) {
                onAction(.remove(item.id))
            }
        }
    }

    private var emptyState: some View {
        EmptyStateCard(
            LocalizedStringResource(
                "Marca tus estaciones habituales",
                comment:
                    "Inicio: título de la sección de favoritas cuando todavía no hay ninguna."
            ),
            message: LocalizedStringResource(
                "Toca la estrella de cualquier estación y la tendrás siempre aquí.",
                comment:
                    "Inicio: explica cómo añadir estaciones favoritas cuando todavía no hay ninguna."
            ),
            systemImage: "star",
            tint: .interactiveFavorite
        ) {
            Button(
                LocalizedStringResource(
                    "Añade una estación",
                    comment:
                        "Inicio: botón del estado vacío de favoritas que abre el selector de estación."
                )
            ) {
                onAction(.addStation)
            }
        }
    }
}

#if DEBUG
private enum FavoriteStationsSamples {
    static let c1 = LineTag(id: "C-1", colorHex: "DA291C")
    static let c2 = LineTag(id: "C-2", colorHex: "0057A8")

    static let figma = [
        StationRowItem(
            id: "54413",
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            distance: "350 m",
            lines: [c1, c2]
        ),
        StationRowItem(
            id: "54404",
            name: "Málaga María Zambrano",
            subtitle: "Centro · Zona A",
            distance: "1,2 km",
            lines: [c1, c2]
        ),
        StationRowItem(
            id: "54412",
            name: "La Colina",
            subtitle: "Carranque · Zona B",
            distance: "2,4 km",
            lines: [c1]
        ),
    ]

    static let many =
        figma + [
            StationRowItem(
                id: "54405",
                name: "Victoria Kent",
                subtitle: nil,
                distance: "3 km",
                lines: [c1, c2]
            ),
            StationRowItem(
                id: "54406",
                name: "Aeropuerto",
                subtitle: "Aeropuerto",
                distance: nil,
                lines: [c1]
            ),
            StationRowItem(
                id: "54407",
                name: "Torremolinos",
                subtitle: "Autobús urbano",
                distance: nil,
                lines: [c1]
            ),
            StationRowItem(
                id: "54408",
                name: "Benalmádena-Arroyo de la Miel",
                subtitle: nil,
                distance: nil,
                lines: [c1]
            ),
            StationRowItem(
                id: "54100",
                name: "Fuengirola",
                subtitle: "Autobús interurbano · Autobús urbano",
                distance: nil,
                lines: [c1]
            ),
            StationRowItem(
                id: "54502",
                name: "Cártama",
                subtitle: nil,
                distance: nil,
                lines: [c2]
            ),
            StationRowItem(
                id: "54503",
                name: "Álora",
                subtitle: "Regional",
                distance: nil,
                lines: [c2]
            ),
        ]
}

private struct FavoriteStationsContainerPreview: View {
    let items: [StationRowItem]
    var viewportHeight: CGFloat = 700

    var body: some View {
        ScrollView {
            FavoriteStationsContainer(items) { _ in }
                .fitsScrollViewport()
        }
        .frame(height: viewportHeight)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    FavoriteStationsContainerPreview(
        items: FavoriteStationsSamples.figma,
        viewportHeight: 330
    )
}

#Preview("Muchas") {
    FavoriteStationsContainerPreview(items: FavoriteStationsSamples.many)
}

#Preview("Vacío") {
    FavoriteStationsContainerPreview(items: [])
}

#Preview("Modo oscuro") {
    FavoriteStationsContainerPreview(
        items: FavoriteStationsSamples.figma,
        viewportHeight: 330
    )
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    FavoriteStationsContainerPreview(items: FavoriteStationsSamples.many)
        .dynamicTypeSize(.accessibility2)
}
#endif
