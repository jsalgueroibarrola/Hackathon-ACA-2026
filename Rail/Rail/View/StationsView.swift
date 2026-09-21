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
            List(stations) { station in
                NavigationLink {
                    StationDetailView(station: station)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.name)
                            .font(.headline)
                        Text(station.lines.map(\.id).sorted().joined(separator: " · "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
