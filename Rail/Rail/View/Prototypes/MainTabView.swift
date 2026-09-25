//
//  MainTabView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

private struct TrackingTrigger: Equatable {
    let isActive: Bool
    let attempt: Int
}

private enum AppTab: Hashable {
    case home, lines, stations, map
}

struct MainTabView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedTab: AppTab = .home
    @State private var mapSelection: String?
    @State private var homePath: [HomeRoute] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Inicio", systemImage: "house", value: .home) {
                HomeView(
                    path: $homePath,
                    onShowMap: showOnMap,
                    onShowStations: showStations
                )
            }

            Tab("Líneas", systemImage: "tram", value: .lines) {
                ContentView()
            }

            Tab("Estaciones", systemImage: "mappin.and.ellipse", value: .stations) {
                StationsView()
            }

            Tab("Mapa", systemImage: "map", value: .map) {
                NetworkMapView(selection: $mapSelection)
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

    private func showStations() {
        selectedTab = .stations
    }
}

#if DEBUG
#Preview(traits: .favoriteStationsSampleData) {
    MainTabView()
        .environment(LocationViewModel.preview())
}
#endif
