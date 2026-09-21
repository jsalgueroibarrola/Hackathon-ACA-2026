//
//  MainTabView.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
