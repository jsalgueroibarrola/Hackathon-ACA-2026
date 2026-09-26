import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var path: [AppRoute]
    let onShowMap: (String) -> Void

    @State private var topInset: CGFloat = 0
    @State private var isShowingAlerts = false

    private static let heroClearance: CGFloat = 80
    private static let heroOverlap: CGFloat = 76

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                content
            }
            .scrollBounceBehavior(.basedOnSize)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentInsets.top
            } action: { _, newValue in
                topInset = newValue
            }
            .background(.bgSecondary)
            .toolbar { toolbar }
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar(removing: .title)
            .appRouteDestinations()
            .sheet(isPresented: $isShowingAlerts) {
                ServiceAlertsSheet()
            }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            NextTrainsSection(onShowMap: onShowMap)
                .padding(.horizontal, ScreenLayout.margin)
                .padding(.top, Self.heroClearance)
            FavoriteStationsSection(onNavigate: { path.append($0) })
                .layoutPriority(-1)
        }
        .fitsScrollViewport()
        .frame(maxWidth: ScreenLayout.maxContentWidth)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) { hero }
    }

    private var hero: some View {
        HomeHeroImage()
            .frame(height: topInset + Self.heroClearance + Self.heroOverlap)
            .offset(y: -topInset)
            .ignoresSafeArea(edges: .horizontal)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            RailLogo()
                .frame(height: Size.touchMin)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Self.title)
                .accessibilityAddTraits(.isHeader)
        }
        .sharedBackgroundVisibility(.hidden)

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(ServiceAlertsSheet.title, systemImage: "bell.fill") {
                isShowingAlerts = true
            }
        }
    }

    static let title = LocalizedStringResource(
        "Inicio",
        comment: "Título de la pestaña y de la pantalla de inicio."
    )
}

#if DEBUG
    #Preview("Con favoritas", traits: .favoriteStationsSampleData) {
        @Previewable @State var path: [AppRoute] = []
        HomeView(path: $path, onShowMap: { _ in })
            .environment(LocationViewModel.preview())
    }

    #Preview("Sin favoritas", traits: .nextTrainsSampleData) {
        @Previewable @State var path: [AppRoute] = []
        HomeView(path: $path, onShowMap: { _ in })
            .environment(LocationViewModel.preview())
    }

    #Preview("Estación guardada", traits: .savedStationSampleData) {
        @Previewable @State var path: [AppRoute] = []
        HomeView(path: $path, onShowMap: { _ in })
            .environment(LocationViewModel.preview(authorization: .denied))
    }

    #Preview("Modo oscuro", traits: .favoriteStationsSampleData) {
        @Previewable @State var path: [AppRoute] = []
        HomeView(path: $path, onShowMap: { _ in })
            .environment(LocationViewModel.preview())
            .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type", traits: .favoriteStationsSampleData) {
        @Previewable @State var path: [AppRoute] = []
        HomeView(path: $path, onShowMap: { _ in })
            .environment(LocationViewModel.preview())
            .dynamicTypeSize(.accessibility2)
    }
#endif
