//
//  StationDetailView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import MapKit
import SwiftData
import SwiftUI

struct StationDetailView: View {
    let station: Station

    @Environment(\.modelContext) private var modelContext
    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query private var favorites: [FavoriteStation]
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @State private var schedules: [StationLineSchedule] = []
    @State private var now: Date = .now
    @State private var routeMode: TravelMode?

    init(station: Station) {
        self.station = station
        let stationID = station.id
        _favorites = Query(
            filter: #Predicate<FavoriteStation> { $0.stationID == stationID }
        )
    }

    private var isFavorite: Bool { !favorites.isEmpty }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: station.latitude,
            longitude: station.longitude
        )
    }

    private var network: TransitNetwork? { networks.first }

    private var timetable: Timetable? { timetables.first }

    private var calendar: Calendar { network?.calendar ?? .autoupdatingCurrent }

    private var timeFormat: Date.FormatStyle {
        .departureTime(in: network?.timeZone ?? .autoupdatingCurrent)
    }

    private var serviceDay: Date { calendar.startOfDay(for: now) }

    private var scheduleKey: String {
        "\(station.id)|\(timetable?.etag ?? timetable?.version ?? "")|\(serviceDay.timeIntervalSinceReferenceDate)"
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

                if let distance = location.distance(to: coordinate) {
                    LabeledContent("Distancia desde tu ubicación") {
                        Text(distance.distanceLabel)
                            .monospacedDigit()
                    }
                }

                if location.isTracking {
                    Button(
                        "Iniciar ruta",
                        systemImage: "location.north.line.fill"
                    ) {
                        routeMode = .walking
                    }
                    .buttonStyle(.rail(.prominent))
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
            }

            TravelEstimatesSection(
                destination: coordinate,
                routeMode: $routeMode
            )

            Section("Horarios de hoy") {
                if schedules.isEmpty {
                    Text("Sin horarios para hoy")
                        .foregroundStyle(.textSecondary)
                } else {
                    ForEach(schedules) { schedule in
                        NavigationLink {
                            StationScheduleView(
                                schedule: schedule,
                                stationName: station.name,
                                timeFormat: timeFormat,
                                now: now
                            )
                        } label: {
                            StationScheduleRow(
                                schedule: schedule,
                                now: now,
                                timeFormat: timeFormat
                            )
                        }
                    }
                }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Toggle(
                    isOn: favoritesModel.binding(
                        for: station.id,
                        isFavorite: isFavorite
                    )
                ) {}
                .toggleStyle(.favorite)
            }
        }
        .sheet(item: $routeMode) { mode in
            RouteView(
                destinationName: station.name,
                destination: coordinate,
                mode: mode
            )
        }
        .task(id: scheduleKey) {
            schedules =
                timetable.map {
                    StationScheduleBuilder.schedules(
                        for: station,
                        timetable: $0,
                        day: serviceDay,
                        calendar: calendar,
                        context: modelContext
                    )
                } ?? []
        }
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(30))
            }
        }
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
    .environment(LocationViewModel.preview())
    .environment(FavoritesViewModel.preview())
    .environment(\.routeEstimates, PreviewRouteService())
    .modelContainer(for: RailSchema.models, inMemory: true)
}
