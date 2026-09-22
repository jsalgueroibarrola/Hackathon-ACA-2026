//
//  MainTabView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(LocationViewModel.self) private var location
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Líneas", systemImage: "tram") {
                ContentView()
            }

            Tab("Estaciones", systemImage: "mappin.and.ellipse") {
                StationsView()
            }

            Tab("Mapa", systemImage: "map") {
                NetworkMapView()
            }
        }
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            await location.observe()
        }
    }
}

#Preview {
    MainTabView()
        .environment(LocationViewModel.preview())
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
