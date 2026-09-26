import MapKit
import SwiftData
import SwiftUI
import UIKit

struct NetworkMapView: View {
    @Query(sort: \Line.id) private var lines: [Line]
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var liveTrains: [LiveTrain]
    @Query private var realtimeFeeds: [RealtimeFeed]
    @Environment(\.routeShapes) private var routeShapes
    @Environment(\.liveFeeds) private var liveFeeds
    @Environment(\.scenePhase) private var scenePhase
    @Environment(LocationViewModel.self) private var location
    @Environment(\.openURL) private var openURL

    @State private var routes: [String: [CLLocationCoordinate2D]] = [:]
    @State private var paths: [String: PolylinePath] = [:]
    @State private var hiddenLineIDs: Set<String> = []
    @Binding var selection: String?
    @State private var detailStationID: String?
    @State private var surface: MapSurface = .muted

    var body: some View {
        NavigationStack {
            NetworkMap(
                lines: overlays,
                pins: visiblePins,
                selection: $selection,
                surface: surface,
                showsUserLocation: location.isTracking,
                trains: trainTracks
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                lineFilter
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let pin = selectedPin {
                    StationCallout(
                        pin: pin,
                        distance: location.distance(to: pin.coordinate)
                    ) {
                        selection = nil
                    } onOpenDetail: {
                        detailStationID = pin.id
                    }
                    .padding(.horizontal, ScreenLayout.margin)
                    .padding(.bottom, Spacing.sm)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy, value: selection)
            .overlay {
                if lines.isEmpty {
                    ContentUnavailableView(
                        LocalizedStringResource(
                            "Sin datos de red",
                            comment: "Mapa: estado vacío cuando no hay líneas guardadas."
                        ),
                        systemImage: "map"
                    )
                    .background(.background)
                }
            }
            .navigationTitle(
                LocalizedStringResource(
                    "Red",
                    comment: "Mapa: título de la pantalla con el mapa de la red de Cercanías."
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    nearestStationButton
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Picker(
                        LocalizedStringResource(
                            "Superficie",
                            comment: "Mapa: menú para elegir el estilo del mapa (estándar, atenuado, híbrido o satélite)."
                        ),
                        selection: $surface
                    ) {
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
            let cache = routeShapes ?? RouteShapeCache()
            await cache.warm(shapes)
            routes = Dictionary(
                uniqueKeysWithValues: shapes.map {
                    ($0.lineID, cache.coordinates(for: $0))
                }
            )
            paths = routes.mapValues(PolylinePath.init)
        }
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            await liveFeeds.poll(.realtime)
        }
    }

    private var trainTracks: [TrainTrack] {
        guard let feed = realtimeFeeds.first else { return [] }
        return TrainTrackBuilder.tracks(
            trains: liveTrains.filter { !hiddenLineIDs.contains($0.lineID) },
            lines: lines,
            paths: paths,
            fetchedAt: feed.feedTimestamp ?? feed.fetchedAt
        )
    }

    private var nearestStationButton: some View {
        Button {
            if location.canRequestAccess {
                location.requestAccess()
            } else if location.isAccessBlocked {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                openURL(url)
            } else if let nearest = nearestVisibleStation {
                selection = nearest.id
            }
        } label: {
            Label(
                LocalizedStringResource(
                    "Estación más cercana",
                    comment: "Mapa: botón que selecciona la estación más cercana al usuario, o pide permiso de ubicación."
                ),
                systemImage: location.isTracking
                    ? "location.magnifyingglass"
                    : "location"
            )
        }
        .labelStyle(.iconOnly)
        .disabled(location.isLocating)
    }

    private var nearestVisibleStation: NearbyStation? {
        let visibleIDs = Set(visiblePins.map(\.id))
        return location.nearest(
            stations.filter { visibleIDs.contains($0.id) },
            limit: 1
        )
        .first
    }

    private var lineFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.sm) {
                ForEach(lines) { line in
                    let isHidden = hiddenLineIDs.contains(line.id)
                    Button {
                        hiddenLineIDs.formSymmetricDifference([line.id])
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(Color(hex: line.colorHex))
                                .frame(width: Self.lineDotSize, height: Self.lineDotSize)
                            Text(line.id)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    .buttonStyle(.glass)
                    .opacity(isHidden ? Self.hiddenLineOpacity : 1)
                }
            }
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.sm)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private static let hiddenLineOpacity = 0.45
    private static let lineDotSize: CGFloat = 8

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

#if DEBUG
#Preview("Trenes en tiempo real", traits: .liveTrainsSampleData) {
    @Previewable @State var selection: String?

    NetworkMapView(selection: $selection)
        .environment(LocationViewModel.preview())
}
#endif
