import CoreLocation
import MapKit
import SwiftUI

struct RouteView: View {
    let destinationName: String
    let destination: CLLocationCoordinate2D

    @Environment(LocationViewModel.self) private var location
    @Environment(\.routeEstimates) private var routeService
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @State private var mode: TravelMode
    @State private var plan: RoutePlan = .locating
    @State private var camera: MapCameraPosition = .automatic

    init(
        destinationName: String,
        destination: CLLocationCoordinate2D,
        mode: TravelMode = .walking
    ) {
        self.destinationName = destinationName
        self.destination = destination
        _mode = State(initialValue: mode)
    }

    private struct Request: Equatable {
        let origin: LocationCell?
        let destination: LocationCell
        let mode: TravelMode
    }

    private var request: Request {
        Request(
            origin: location.location?.cell,
            destination: destination.cell,
            mode: mode
        )
    }

    private var destinationFraming: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: destination,
                latitudinalMeters: 900,
                longitudinalMeters: 900
            )
        )
    }

    var body: some View {
        NavigationStack {
            routeMap
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RouteDirectionsPanel(
                        plan: plan,
                        mode: $mode,
                        onOpenInMaps: { openInMaps() }
                    )
                    .padding(.horizontal, ScreenLayout.margin)
                    .padding(.bottom, Spacing.sm)
                }
                .animation(.snappy, value: plan.route?.id)
                .navigationTitle(destinationName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Cerrar", systemImage: "xmark")
                        }
                        .labelStyle(.iconOnly)
                    }
                }
                .task(id: request) {
                    await calculate()
                }
        }
    }

    private var routeMap: some View {
        Map(position: $camera) {
            if let route = plan.route, route.coordinates.count > 1 {
                MapPolyline(coordinates: route.coordinates)
                    .stroke(
                        .background.opacity(0.9),
                        style: StrokeStyle(
                            lineWidth: 11,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .mapOverlayLevel(level: .aboveRoads)

                MapPolyline(coordinates: route.coordinates)
                    .stroke(
                        Color.brandPrimary,
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .mapOverlayLevel(level: .aboveLabels)
            }

            if location.isTracking {
                UserAnnotation()
            }

            Marker(
                destinationName,
                systemImage: "tram.fill",
                coordinate: destination
            )
            .tint(Color.brandPrimary)
        }
        .mapStyle(.standard(elevation: .flat))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }

    private func calculate() async {
        guard let origin = location.location?.coordinate else {
            plan = .locating
            camera = destinationFraming
            return
        }

        plan = .calculating

        let next: RoutePlan
        if mode.supportsDirections {
            do {
                next = .directions(
                    try await routeService.route(
                        from: origin,
                        to: destination,
                        mode: mode
                    )
                )
            } catch {
                next = .failure(error)
            }
        } else {
            next =
                await routeService
                .estimates(from: origin, to: destination, modes: [mode])[mode]
                .map(RoutePlan.estimate) ?? .failure(.unavailable)
        }

        guard !Task.isCancelled else { return }
        plan = next
        camera =
            next.route?.coordinates.boundingRect().map(MapCameraPosition.rect)
            ?? destinationFraming
    }

    private func openInMaps() {
        var components = URLComponents(
            string: "https://maps.apple.com/directions"
        )
        components?.queryItems = [
            URLQueryItem(
                name: "destination",
                value: "\(destination.latitude),\(destination.longitude)"
            ),
            URLQueryItem(name: "mode", value: "transit"),
        ]
        guard let url = components?.url else { return }
        openURL(url)
    }
}

// MARK: - Previews

extension CLLocationCoordinate2D {
    fileprivate static let perchel = CLLocationCoordinate2D(
        latitude: 36.7139,
        longitude: -4.4322
    )
}

#Preview("Andando") {
    RouteView(destinationName: "El Perchel", destination: .perchel)
        .environment(LocationViewModel.preview())
        .environment(\.routeEstimates, PreviewRouteService())
}

#Preview("En coche") {
    RouteView(
        destinationName: "El Perchel",
        destination: .perchel,
        mode: .automobile
    )
    .environment(LocationViewModel.preview())
    .environment(\.routeEstimates, PreviewRouteService())
}

#Preview("Transporte público") {
    RouteView(
        destinationName: "El Perchel",
        destination: .perchel,
        mode: .transit
    )
    .environment(LocationViewModel.preview())
    .environment(
        \.routeEstimates,
        PreviewRouteService(
            values: [
                .transit: TravelEstimate(
                    mode: .transit,
                    travelTime: .seconds(900),
                    distance: Measurement(value: 2031, unit: .meters),
                    departure: Date(timeIntervalSince1970: 1_790_000_000),
                    arrival: Date(timeIntervalSince1970: 1_790_000_900)
                )
            ]
        )
    )
}

#Preview("Sin ubicación") {
    RouteView(destinationName: "El Perchel", destination: .perchel)
        .environment(LocationViewModel.preview(location: nil))
        .environment(\.routeEstimates, PreviewRouteService())
}
