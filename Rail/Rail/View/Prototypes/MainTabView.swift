import SwiftUI
import SwiftData

private struct TrackingTrigger: Equatable {
    let isActive: Bool
    let attempt: Int
}

private enum AppTab: Hashable {
    case home, map, stations
}

struct MainTabView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedTab: AppTab = .home
    @State private var mapSelection: String?
    @State private var homePath: [AppRoute] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .home) {
                HomeView(path: $homePath, onShowMap: showOnMap)
            } label: {
                Label(HomeView.title, systemImage: "house")
            }

            Tab(value: .map) {
                NetworkMapView(selection: $mapSelection)
            } label: {
                Label(Self.mapTitle, systemImage: "map")
            }

            Tab(value: .stations) {
                StationsView()
            } label: {
                Label(StationsView.title, systemImage: "mappin.and.ellipse")
            }
        }
        .task(
            id: TrackingTrigger(
                isActive: scenePhase == .active,
                attempt: location.retryAttempt
            )
        ) {
            guard scenePhase == .active else { return }
            await location.observe()
        }
        .onOpenURL { url in
            if let stationID = RailWidgetLink.stationID(from: url) {
                showStation(stationID)
            }
        }
    }

    private func showStation(_ stationID: String) {
        selectedTab = .home
        homePath = [.station(id: stationID)]
    }

    private func showOnMap(_ stationID: String) {
        mapSelection = stationID
        selectedTab = .map
    }

    private static let mapTitle = LocalizedStringResource(
        "Mapa",
        comment: "Título de la pestaña con el mapa de la red."
    )
}

#if DEBUG
#Preview(traits: .favoriteStationsSampleData) {
    MainTabView()
        .environment(LocationViewModel.preview())
}
#endif
