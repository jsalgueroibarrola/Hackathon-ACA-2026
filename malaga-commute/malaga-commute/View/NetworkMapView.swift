//
//  NetworkMapView.swift
//  malaga-commute
//
//  Created by jakuru on 21/09/2026.
//

import MapKit
import SwiftData
import SwiftUI

struct NetworkMapView: View {
    @Query(sort: \Line.id) private var lines: [Line]
    @Query(sort: \Station.name) private var stations: [Station]
    @Environment(\.routeShapes) private var routeShapes

    @State private var routes: [String: [CLLocationCoordinate2D]] = [:]
    @State private var hiddenLineIDs: Set<String> = []
    @State private var selection: String?
    @State private var detailStationID: String?
    @State private var surface: MapSurface = .muted

    var body: some View {
        NavigationStack {
            NetworkMap(
                lines: overlays,
                pins: visiblePins,
                selection: $selection,
                surface: surface
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                lineFilter
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let pin = selectedPin {
                    StationCallout(pin: pin) {
                        selection = nil
                    } onOpenDetail: {
                        detailStationID = pin.id
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy, value: selection)
            .overlay {
                if lines.isEmpty {
                    ContentUnavailableView(
                        "Sin datos de red",
                        systemImage: "map"
                    )
                    .background(.background)
                }
            }
            .navigationTitle("Red")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Superficie", selection: $surface) {
                        ForEach(MapSurface.allCases) { surface in
                            Text(surface.title).tag(surface)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationDestination(item: $detailStationID) { id in
                if let station = stations.first(where: { $0.id == id }) {
                    StationDetailView(station: station)
                }
            }
        }
        .task(id: lines.map(\.shape)) {
            let shapes = lines.map(\.routeShape)
            await routeShapes.warm(shapes)
            routes = Dictionary(
                uniqueKeysWithValues: shapes.map {
                    ($0.lineID, routeShapes.coordinates(for: $0))
                }
            )
        }
    }

    private var lineFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(lines) { line in
                    let isHidden = hiddenLineIDs.contains(line.id)
                    Button {
                        if isHidden {
                            hiddenLineIDs.remove(line.id)
                        } else {
                            hiddenLineIDs.insert(line.id)
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color(hex: line.colorHex))
                                .frame(width: 8, height: 8)
                            Text(line.id)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    .buttonStyle(.glass)
                    .opacity(isHidden ? 0.45 : 1)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private var overlays: [LineOverlay] {
        lines
            .filter { !hiddenLineIDs.contains($0.id) }
            .map { LineOverlay(line: $0, coordinates: routes[$0.id] ?? []) }
    }

    private var visiblePins: [StationPin] {
        let pins = stations.map(StationPin.init)
        guard !hiddenLineIDs.isEmpty else { return pins }
        return pins.filter { pin in
            pin.lineIDs.isEmpty
                || pin.lineIDs.contains { !hiddenLineIDs.contains($0) }
        }
    }

    private var selectedPin: StationPin? {
        guard let selection else { return nil }
        return visiblePins.first { $0.id == selection }
    }
}
