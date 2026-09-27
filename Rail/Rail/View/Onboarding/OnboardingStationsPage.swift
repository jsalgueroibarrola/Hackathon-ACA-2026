import SwiftData
import SwiftUI

struct OnboardingStationsPage: View {
    private let hasDownloadFailed: Bool
    private let onFinish: () -> Void

    @Environment(LocationViewModel.self) private var location
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Query private var lines: [Line]
    @Query private var favorites: [FavoriteStation]
    @State private var isPickingStations = false

    init(hasDownloadFailed: Bool, onFinish: @escaping () -> Void) {
        self.hasDownloadFailed = hasDownloadFailed
        self.onFinish = onFinish
    }

    private var topInset: CGFloat {
        verticalSizeClass == .compact ? Spacing.lg : OnboardingLayout.regularTopInset
    }

    private var favoriteIDs: Set<String> {
        Set(favorites.map(\.stationID))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                OnboardingHeader(Self.title, message: Self.message)
                stations
            }
            .padding(.top, topInset)
            .padding(.bottom, Spacing.lg)
            .onboardingColumn()
        }
        .sheet(isPresented: $isPickingStations) {
            StationPickerSheet(.favorites)
        }
        .safeAreaBar(edge: .bottom) {
            OnboardingActionBar(
                primary: .start(onFinish),
                secondary: .init(title: Self.skipLabel, perform: onFinish)
            )
        }
    }

    @ViewBuilder
    private var stations: some View {
        if lines.isEmpty {
            card { unavailable }
        } else {
            let favoriteIDs = favoriteIDs
            card {
                rows(
                    OnboardingStationsBuilder.items(
                        lines: lines,
                        favoriteIDs: favoriteIDs,
                        location: location.location
                    ),
                    favoriteIDs: favoriteIDs
                )
            }
            Button(Self.allStationsLabel, systemImage: "magnifyingglass") {
                isPickingStations = true
            }
            .buttonStyle(.rail(.bordered))
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .frame(maxWidth: .infinity)
            .background(.bgPrimary, in: .rect(cornerRadius: Radius.xl, style: .continuous))
    }

    private func rows(_ items: [StationRowItem], favoriteIDs: Set<String>) -> some View {
        ForEach(items) { item in
            FavoriteToggleRow(
                item: item,
                isFavorite: favoriteIDs.contains(item.id),
                showsSeparator: item.id != items.last?.id
            )
        }
    }

    @ViewBuilder
    private var unavailable: some View {
        if hasDownloadFailed {
            CardMessage(
                Self.failedTitle,
                message: Self.failedMessage,
                icon: .symbol("wifi.slash", tint: .textTertiary),
                prominence: .compact
            )
        } else {
            CardMessage(Self.loadingTitle, icon: .progress, prominence: .compact)
        }
    }

    private static let title = LocalizedStringResource(
        "¿Cuáles son tus estaciones habituales?",
        comment: "Bienvenida, paso 4: título de la lista de estaciones para marcar favoritas."
    )

    private static let message = LocalizedStringResource(
        "Márcalas como favoritas y las verás nada más abrir Rail.",
        comment: "Bienvenida, paso 4: explica que las estaciones con estrella aparecen en Inicio."
    )

    private static let skipLabel = LocalizedStringResource(
        "Saltar por ahora",
        comment: "Bienvenida, paso 4: botón secundario que termina la bienvenida sin marcar favoritas."
    )

    private static let loadingTitle = LocalizedStringResource(
        "Descargando estaciones…",
        comment: "Bienvenida, paso 4: mensaje mientras se descargan las estaciones por primera vez."
    )

    private static let failedTitle = LocalizedStringResource(
        "No se han podido descargar las estaciones",
        comment: "Bienvenida, paso 4: título cuando falla la primera descarga de datos."
    )

    private static let failedMessage = LocalizedStringResource(
        "Podrás marcar tus favoritas más tarde desde Estaciones.",
        comment: "Bienvenida, paso 4: explica dónde marcar favoritas cuando la descarga ha fallado. «Estaciones» es el nombre de la pestaña."
    )

    private static let allStationsLabel = LocalizedStringResource(
        "Ver todas las estaciones",
        comment: "Bienvenida, paso 4: botón bajo las estaciones sugeridas que abre una hoja con todas las estaciones y un buscador."
    )
}

#if DEBUG
#Preview("Variantes Figma", traits: .favoriteStationsSampleData) {
    OnboardingStationsPage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
}

#Preview("Con ubicación", traits: .favoriteStationsSampleData) {
    OnboardingStationsPage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(location: .alameda))
}

#Preview("Descargando") {
    OnboardingStationsPage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
        .environment(FavoritesViewModel.preview())
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Sin conexión") {
    OnboardingStationsPage(hasDownloadFailed: true) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
        .environment(FavoritesViewModel.preview())
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Modo oscuro", traits: .favoriteStationsSampleData) {
    OnboardingStationsPage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type", traits: .favoriteStationsSampleData) {
    OnboardingStationsPage(hasDownloadFailed: false) {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
        .dynamicTypeSize(.accessibility2)
}
#endif
