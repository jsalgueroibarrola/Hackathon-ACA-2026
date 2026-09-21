//
//  StationDetailView.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI
import SwiftData
import MapKit

struct StationDetailView: View {
    let station: Station

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: station.latitude,
            longitude: station.longitude
        )
    }

    var body: some View {
        List {
            Section {
                Map(
                    initialPosition: .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            latitudinalMeters: 800,
                            longitudinalMeters: 800
                        )
                    )
                ) {
                    Marker(station.name, coordinate: coordinate)
                }
                .frame(height: 200)
                .listRowInsets(EdgeInsets())
            }

            Section("Líneas") {
                ForEach(station.lines.sorted { $0.id < $1.id }) { line in
                    LabeledContent(line.id, value: line.name)
                }
            }

            Section("Accesibilidad") {
                LabeledContent("Movilidad reducida") {
                    AvailabilityText(isAvailable: station.isAccessible)
                }
                LabeledContent("Ascensor") {
                    AvailabilityText(isAvailable: station.hasElevator)
                }
            }

            if !station.connections.isEmpty {
                Section("Conexiones") {
                    ForEach(station.connections, id: \.self) { connection in
                        Text(connection.displayName)
                    }
                }
            }

            Section("Identificador") {
                Text(station.id)
                    .monospaced()
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(station.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AvailabilityText: View {
    let isAvailable: Bool?

    var body: some View {
        if isAvailable == true {
            Text("Sí")
        } else {
            Text("Sin datos")
        }
    }
}

#Preview {
    let station = Station(
        id: "54413",
        name: "Málaga-Centro Alameda",
        latitude: 36.717,
        longitude: -4.425,
        isAccessible: true,
        connections: [.metro, .urbanBus]
    )

    return NavigationStack {
        StationDetailView(station: station)
    }
    .modelContainer(for: TransitNetwork.self, inMemory: true)
}
