//
//  LineDetailView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct LineDetailView: View {
    let line: Line

    @Environment(\.routeShapes) private var routeShapes
    @State private var route: [CLLocationCoordinate2D] = []

    var body: some View {
        List {
            Section {
                Map(initialPosition: .automatic) {
                    if !route.isEmpty {
                        MapPolyline(coordinates: route)
                            .stroke(Color(hex: line.colorHex), lineWidth: 4)
                    }
                    ForEach(line.orderedStops, id: \.stationID) { stop in
                        if let station = stop.station {
                            Marker(
                                station.name,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: station.latitude,
                                    longitude: station.longitude
                                )
                            )
                            .tint(Color(hex: line.colorHex))
                        }
                    }
                }
                .frame(height: 280)
                .listRowInsets(EdgeInsets())
            }

            Section("Recorrido") {
                ForEach(line.orderedStops, id: \.stationID) { stop in
                    if let station = stop.station {
                        NavigationLink {
                            StationDetailView(station: station)
                        } label: {
                            LabeledContent(
                                station.name,
                                value: stop.sequence + 1,
                                format: .number
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle(line.id)
        .navigationSubtitle(line.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: line.shape) {
            route = routeShapes.coordinates(for: line.routeShape)
        }
    }
}

#Preview {
    NavigationStack {
        LineDetailView(
            line: Line(
                id: "C1",
                name: "Málaga-Centro Alameda – Fuengirola",
                colorHex: "4A8CCC",
                shape: "_ymtFvvq^dCuAfGaDbBcA"
            )
        )
    }
    .modelContainer(for: TransitNetwork.self, inMemory: true)
}
