//
//  NetworkMap.swift
//  Rail
//
//  Created by jakuru on 21/09/2026.
//

import MapKit
import SwiftUI

private struct TrainClock: Equatable {
    let isRunning: Bool
    let reduceMotion: Bool
}

struct NetworkMap: View {
    let lines: [LineOverlay]
    let pins: [StationPin]
    @Binding var selection: String?
    var surface: MapSurface = .muted
    var showsCasing: Bool = true
    var showsUserLocation: Bool = false
    var trains: [TrainTrack] = []

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var camera: MapCameraPosition = .automatic
    @State private var zoom: ZoomBucket = .region
    @State private var heading: CLLocationDirection = 0
    @State private var now = Date.now
    @State private var hasFramed = false

    var body: some View {
        Map(
            position: $camera,
            bounds: MapCameraBounds(
                minimumDistance: 200,
                maximumDistance: 400_000
            ),
            selection: $selection
        ) {
            ForEach(lines) { line in
                polyline(for: line)
            }

            if showsUserLocation {
                UserAnnotation()
            }

            ForEach(liveTrains) { train in
                let position = train.position(at: now)
                Annotation(coordinate: position.coordinate) {
                    TrainMarker(
                        tint: LineTint(base: Color(hex: train.colorHex)),
                        rotation: .degrees(position.bearing - heading),
                        isStale: train.isStale(at: now)
                    )
                    .accessibilityLabel(train.accessibilityLabel)
                } label: {
                    Text(verbatim: train.train)
                }
                .annotationTitles(.hidden)
            }

            ForEach(pins) { pin in
                Annotation(coordinate: pin.coordinate) {
                    BadgedStationPin(
                        pin: pin,
                        zoom: zoom,
                        isSelected: pin.id == selection
                    )
                } label: {
                    Text(pin.name)
                }
                .tag(pin.id)
                .annotationTitles(zoom >= .street ? .visible : .hidden)
            }
        }
        .mapStyle(surface.mapStyle)
        .mapControls {
            if showsUserLocation {
                MapUserLocationButton()
            }
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .continuous) { context in
            let bucket = zoom.updated(for: context.camera.distance)
            if bucket != zoom { zoom = bucket }
            if context.camera.heading != heading { heading = context.camera.heading }
        }
        .task(id: TrainClock(isRunning: !trains.isEmpty, reduceMotion: reduceMotion)) {
            guard !trains.isEmpty else { return }
            let step: Duration = reduceMotion ? .seconds(5) : .seconds(1)
            now = .now
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: step)
                } catch {
                    return
                }
                withAnimation(reduceMotion ? nil : .linear(duration: 1)) {
                    now = .now
                }
            }
        }
        .task(id: pins.count) {
            guard !hasFramed, let boundingRect else { return }
            hasFramed = true
            camera = .rect(boundingRect)
        }
    }

    @MapContentBuilder
    private func polyline(for line: LineOverlay) -> some MapContent {
        if !line.coordinates.isEmpty {
            if showsCasing {
                MapPolyline(
                    coordinates: line.coordinates,
                    contourStyle: .geodesic
                )
                .stroke(
                    .background.opacity(0.9),
                    style: StrokeStyle(
                        lineWidth: 9,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .mapOverlayLevel(level: .aboveRoads)
            }

            MapPolyline(coordinates: line.coordinates, contourStyle: .geodesic)
                .stroke(
                    line.color,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .mapOverlayLevel(level: .aboveLabels)
        }
    }

    private var liveTrains: [TrainTrack] {
        trains.filter { !$0.isExpired(at: now) }
    }

    private var boundingRect: MKMapRect? {
        let points =
            pins.map { MKMapPoint($0.coordinate) }
            + lines.flatMap { $0.coordinates.map(MKMapPoint.init) }
        guard !points.isEmpty else { return nil }

        var rect = MKMapRect.null
        for point in points {
            rect = rect.union(
                MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            )
        }
        return rect.insetBy(dx: -rect.width * 0.15, dy: -rect.height * 0.15)
    }
}

// MARK: - Previews

extension LineOverlay {
    fileprivate static let l1 = LineOverlay(
        id: "L1",
        name: "Andalucía Tech – Atarazanas",
        colorHex: "E1251B",
        coordinates: [
            CLLocationCoordinate2D(latitude: 36.7196, longitude: -4.4249),
            CLLocationCoordinate2D(latitude: 36.7203, longitude: -4.4291),
            CLLocationCoordinate2D(latitude: 36.7139, longitude: -4.4322),
            CLLocationCoordinate2D(latitude: 36.7114, longitude: -4.4412),
            CLLocationCoordinate2D(latitude: 36.7091, longitude: -4.4535),
            CLLocationCoordinate2D(latitude: 36.7060, longitude: -4.4680),
        ]
    )

    fileprivate static let l2 = LineOverlay(
        id: "L2",
        name: "Palacio de los Deportes – Atarazanas",
        colorHex: "5C2D91",
        coordinates: [
            CLLocationCoordinate2D(latitude: 36.7196, longitude: -4.4249),
            CLLocationCoordinate2D(latitude: 36.7203, longitude: -4.4291),
            CLLocationCoordinate2D(latitude: 36.7139, longitude: -4.4322),
            CLLocationCoordinate2D(latitude: 36.7185, longitude: -4.4620),
            CLLocationCoordinate2D(latitude: 36.7209, longitude: -4.4735),
        ]
    )
}

extension StationPin {
    fileprivate static let red: [StationPin] = [
        StationPin(
            id: "atarazanas",
            name: "Atarazanas",
            latitude: 36.7196,
            longitude: -4.4249,
            isAccessible: true,
            hasElevator: true,
            connections: [.urbanBus],
            lineIDs: ["L1", "L2"],
            colorHexes: ["E1251B", "5C2D91"]
        ),
        StationPin(
            id: "guadalmedina",
            name: "Guadalmedina",
            latitude: 36.7203,
            longitude: -4.4291,
            isAccessible: true,
            lineIDs: ["L1", "L2"],
            colorHexes: ["E1251B", "5C2D91"]
        ),
        StationPin(
            id: "el-perchel",
            name: "El Perchel",
            latitude: 36.7139,
            longitude: -4.4322,
            isAccessible: true,
            hasElevator: true,
            connections: [.ave, .regional, .busStation],
            lineIDs: ["L1", "L2"],
            colorHexes: ["E1251B", "5C2D91"]
        ),
        StationPin(
            id: "principe-asturias",
            name: "Príncipe de Asturias",
            latitude: 36.7114,
            longitude: -4.4412,
            lineIDs: ["L1"],
            colorHexes: ["E1251B"]
        ),
        StationPin(
            id: "portada-alta",
            name: "Portada Alta",
            latitude: 36.7185,
            longitude: -4.4620,
            isAccessible: true,
            connections: [.interurbanBus],
            lineIDs: ["L2"],
            colorHexes: ["5C2D91"]
        ),
    ]
}

#Preview("Red") {
    @Previewable @State var selection: String?

    NetworkMap(lines: [.l1, .l2], pins: StationPin.red, selection: $selection)
}

#Preview("Seleccionada") {
    @Previewable @State var selection: String? = "el-perchel"

    NetworkMap(lines: [.l1, .l2], pins: StationPin.red, selection: $selection)
}

#Preview("Satélite") {
    @Previewable @State var selection: String?

    NetworkMap(
        lines: [.l1, .l2],
        pins: StationPin.red,
        selection: $selection,
        surface: .imagery
    )
}

#Preview("Sin contorno") {
    @Previewable @State var selection: String?

    NetworkMap(
        lines: [.l1, .l2],
        pins: StationPin.red,
        selection: $selection,
        showsCasing: false
    )
}

extension TrainTrack {
    fileprivate static func sample(
        _ train: String,
        on line: LineOverlay,
        direction: TripDirection,
        from start: Double,
        to end: Double,
        status: LiveStatus = .left
    ) -> TrainTrack {
        let path = PolylinePath(line.coordinates)
        return TrainTrack(
            id: "\(line.id)-\(train)",
            lineID: line.id,
            colorHex: line.colorHex,
            train: train,
            direction: direction,
            headsign: nil,
            delaySeconds: nil,
            status: status,
            sampledAt: .now,
            path: path,
            startDistance: path.length * start,
            endDistance: path.length * end
        )
    }

    fileprivate static let red: [TrainTrack] = [
        .sample("23501", on: .l1, direction: .outbound, from: 0.1, to: 0.45),
        .sample("23506", on: .l1, direction: .inbound, from: 0.8, to: 0.55),
        .sample("26003", on: .l2, direction: .outbound, from: 0.5, to: 0.5, status: .at),
    ]
}

#Preview("Trenes en tiempo real") {
    @Previewable @State var selection: String?

    NetworkMap(
        lines: [.l1, .l2],
        pins: StationPin.red,
        selection: $selection,
        trains: TrainTrack.red
    )
}

#Preview("Solo líneas") {
    @Previewable @State var selection: String?

    NetworkMap(lines: [.l1, .l2], pins: [], selection: $selection)
}
