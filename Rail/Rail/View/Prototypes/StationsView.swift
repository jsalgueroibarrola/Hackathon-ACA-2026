//
//  StationsView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData

struct StationsView: View {
    @Query(sort: \Station.name) private var stations: [Station]

    var body: some View {
        NavigationStack {
            List {
                NearbyStationsSection(stations: stations)

                Section("Todas las estaciones") {
                    ForEach(stations) { station in
                        NavigationLink {
                            StationDetailView(station: station)
                        } label: {
                            StationRow(station: station)
                        }
                    }
                }
            }
            .overlay {
                if stations.isEmpty {
                    ContentUnavailableView(
                        "Sin estaciones",
                        systemImage: "mappin.slash"
                    )
                }
            }
            .navigationTitle("Estaciones")
        }
    }
}

#Preview {
    StationsView()
        .environment(LocationViewModel.preview())
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
