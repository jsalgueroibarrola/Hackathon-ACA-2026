import SwiftData
import SwiftUI

struct StationSheetHeader: View {
    let station: Station?
    let onClose: () -> Void

    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query private var favorites: [FavoriteStation]
    @AccessibilityFocusState private var isTitleFocused: Bool

    init(station: Station?, onClose: @escaping () -> Void) {
        self.station = station
        self.onClose = onClose
        let stationID = station?.id ?? ""
        _favorites = Query(
            filter: #Predicate<FavoriteStation> { $0.stationID == stationID }
        )
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            title
                .font(.title2Emphasized)
                .foregroundStyle(.textPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($isTitleFocused)
            if let station {
                Toggle(
                    isOn: favoritesModel.binding(
                        for: station.id,
                        isFavorite: !favorites.isEmpty
                    )
                ) {}
                .toggleStyle(.favorite)
            }
            Button(role: .close, action: onClose) {
                Label(Self.closeTitle, systemImage: "xmark")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .controlSize(.large)
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.bottom, Spacing.sm)
        .task(id: station?.id) {
            isTitleFocused = true
        }
    }

    private var title: Text {
        station.map { Text(verbatim: $0.name) } ?? Text(Self.unavailableTitle)
    }

    private static let closeTitle = LocalizedStringResource(
        "Cerrar",
        comment: "Mapa, ficha de estación: botón que cierra la ficha y vuelve al carrusel."
    )

    private static let unavailableTitle = LocalizedStringResource(
        "Estación no disponible",
        comment:
            "Detalle de estación: la estación ya no está en los datos descargados."
    )
}
