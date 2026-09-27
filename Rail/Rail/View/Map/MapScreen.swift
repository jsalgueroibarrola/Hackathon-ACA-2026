import MapKit
import SwiftData
import SwiftUI

struct MapScreen: View {
    @Binding var request: String?
    @Binding var path: [AppRoute]

    @Query(sort: \Line.id) private var lines: [Line]
    @Query(sort: \Station.name) private var stations: [Station]
    @Query private var liveTrains: [LiveTrain]
    @Query private var realtimeFeeds: [RealtimeFeed]
    @Environment(\.routeShapes) private var routeShapes
    @Environment(\.liveFeeds) private var liveFeeds
    @Environment(\.connectivity) private var connectivity
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(LocationViewModel.self) private var location

    @State private var selection: String?
    @State private var camera: MapCameraPosition = .automatic
    @State private var routes: [String: [CLLocationCoordinate2D]] = [:]
    @State private var paths: [String: PolylinePath] = [:]
    @State private var lineFilter: String?
    @State private var nearbyFocusID: String?
    @State private var sheet = MapSheetModel()
    @State private var isOnline = true
    @State private var hasLoadedTrains = false
    @ScaledMetric(relativeTo: .headline) private var bottomReserve: CGFloat = 150
    @Namespace private var mapScope

    var body: some View {
        NavigationStack(path: $path) {
            TransitMap(
                camera: $camera,
                selection: mapSelection,
                focusedID: nearbyFocusID,
                lines: overlays,
                pins: visiblePins,
                trains: trainTracks,
                trainsHiddenAfter: MapFeedStatus.trainsHiddenAfter(
                    isOnline: isOnline,
                    fetchedAt: realtimeFeeds.first?.fetchedAt
                ),
                showsUserLocation: location.isTracking,
                scope: mapScope
            )
            .overlay(alignment: .topTrailing) {
                MapCompass(scope: mapScope)
                    .padding(ScreenLayout.margin)
            }
            .safeAreaPadding(.bottom, bottomReserve)
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack(spacing: 0) {
                    LineFilterBar(
                        StationPickerSectionBuilder.lineIDs(lines),
                        selection: $lineFilter
                    )
                    if let feedStatus {
                        MapFeedStatusBadge(status: feedStatus)
                            .padding(.trailing, ScreenLayout.margin)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .animation(reduceMotion ? nil : .smooth, value: feedStatus)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    sheet.measure(\.topInset, height)
                }
            }
            .overlay {
                MapBottomLayer(
                    model: sheet,
                    isPresented: selection != nil,
                    carousel: carousel,
                    controls: controls,
                    sheet: stationSheet
                )
            }
            .overlay {
                if lines.isEmpty {
                    ContentUnavailableView(Self.emptyTitle, systemImage: "map")
                        .background(.bgSecondary)
                }
            }
            .mapScope(mapScope)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .appRouteDestinations()
        }
        .task(id: lines.map(\.shape)) {
            await loadRoutes()
        }
        .task {
            for await online in connectivity.updates() {
                isOnline = online
            }
        }
        .task(id: LivePolling(isActive: scenePhase == .active, isOnline: isOnline)) {
            guard scenePhase == .active, isOnline else { return }
            await liveFeeds.poll(.realtime) { refresh in
                if refresh.outcome != .failed { hasLoadedTrains = true }
            }
        }
        .onChange(of: request, initial: true) { _, stationID in
            guard let stationID else { return }
            request = nil
            reveal(stationID)
        }
        .onChange(of: selection) { _, stationID in
            guard let stationID else { return }
            focus(on: stationID, lift: sheetLift)
        }
    }

    private var carousel: some View {
        NearbyStations(
            stations: visibleStations,
            fallback: nearbyFallback,
            selectedID: selection,
            focusedID: $nearbyFocusID,
            onOpen: { show($0, fromCard: true) },
            onBrowse: { stationID in
                guard selection == nil else { return }
                focus(on: stationID, lift: 0)
            },
            onShowNetwork: showNetwork
        )
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            sheet.measure(\.cardHeight, height)
        }
    }

    private var controls: some View {
        MapControls(camera: $camera, onShowNetwork: showNetwork)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                sheet.measure(\.controlsSize, size)
            }
    }

    private var stationSheet: StationSheet? {
        (selection ?? sheet.lastStationID).map { stationID in
            StationSheet(
                stationID: stationID,
                bodyScrolls: metrics.bodyOverflows,
                actions: MapSheetActions(
                    drag: handleSheetDrag,
                    close: close,
                    measure: measure
                )
            )
        }
    }

    private var metrics: MapSheetMetrics {
        MapSheetLayout.metrics(
            sheet.measurements,
            isRegularWidth: horizontalSizeClass == .regular
        )
    }

    private var mapSelection: Binding<String?> {
        Binding {
            selection
        } set: { stationID in
            if let stationID {
                show(stationID, fromCard: stationID == nearbyFocusID)
            } else {
                close()
            }
        }
    }

    private func reveal(_ stationID: String) {
        guard selection != stationID else {
            return focus(on: stationID, lift: sheetLift)
        }
        show(stationID, fromCard: false)
    }

    private func show(_ stationID: String, fromCard: Bool) {
        guard selection == nil else {
            withAnimation(MapSheetMotion.contentSwap) {
                sheet.lastStationID = stationID
                selection = stationID
            }
            return
        }
        open(stationID, from: fromCard ? origin(for: stationID) : .bottom)
    }

    private func open(_ stationID: String, from origin: MapSheetOrigin) {
        withAnimation(MapSheetMotion.settle(reduceMotion: reduceMotion)) {
            sheet.origin = origin
            sheet.dragTranslation = nil
            sheet.lastStationID = stationID
            selection = stationID
        }
    }

    private func close() {
        guard let stationID = selection else { return }
        withAnimation(MapSheetMotion.dismiss(reduceMotion: reduceMotion)) {
            sheet.origin = origin(for: stationID)
            sheet.dragTranslation = nil
            sheet.lastStationID = stationID
            selection = nil
        }
    }

    private func measure(_ part: MapSheetPart, _ height: CGFloat) {
        switch part {
        case .header: sheet.measure(\.headerHeight, height)
        case .content: sheet.measure(\.contentHeight, height)
        }
    }

    private func origin(for stationID: String) -> MapSheetOrigin {
        carouselStationIDs.contains(stationID) ? .card(stationID) : .bottom
    }

    private var carouselStationIDs: Set<String> {
        Set(
            NearbyCarouselBuilder.items(
                authorization: location.authorization,
                location: location.location,
                hasLocationFailed: location.hasLocationFailed,
                stations: visibleStations,
                fallback: nearbyFallback
            )
            .compactMap { item in
                guard case .station(let station) = item else { return nil }
                return station.id
            }
        )
    }

    private func handleSheetDrag(_ event: VerticalDragEvent) {
        guard let stationID = selection else { return }
        switch event {
        case .changed(let translation):
            if sheet.dragTranslation == nil {
                sheet.origin = origin(for: stationID)
            }
            withAnimation(MapSheetMotion.tracking) {
                sheet.dragTranslation = translation
            }
        case .ended(_, let predicted):
            settleSheet(projectedTranslation: predicted)
        case .cancelled:
            settleSheet(projectedTranslation: sheet.dragTranslation ?? 0)
        }
    }

    private func settleSheet(projectedTranslation: CGFloat) {
        guard !MapSheetLayout.shouldClose(projectedTranslation: projectedTranslation, metrics: metrics) else {
            return close()
        }
        withAnimation(MapSheetMotion.settle(reduceMotion: reduceMotion)) {
            sheet.dragTranslation = nil
        }
    }

    private var sheetLift: Double {
        let metrics = metrics
        let centerX = metrics.container.width / 2
        guard metrics.sheetMinX < centerX, metrics.sheetMinX + metrics.sheetWidth > centerX else {
            return 0
        }
        return MapCameraBuilder.lift(
            covering: metrics.height + MapSheetLayout.baselineGap,
            reserved: bottomReserve,
            viewport: CGSize(
                width: metrics.container.width,
                height: metrics.container.height - metrics.topInset - bottomReserve
            )
        )
    }

    private func focus(on stationID: String, lift: Double) {
        guard let station = stations.first(where: { $0.id == stationID }) else {
            return
        }
        withAnimation(reduceMotion ? nil : MapSheetMotion.camera) {
            camera = .region(
                MapCameraBuilder.region(focusing: station.coordinate, lift: lift)
            )
        }
    }

    private func loadRoutes() async {
        let shapes = lines.map(\.routeShape)
        let cache = routeShapes ?? RouteShapeCache()
        await cache.warm(shapes)
        routes = Dictionary(
            uniqueKeysWithValues: shapes.map {
                ($0.lineID, cache.coordinates(for: $0))
            }
        )
        paths = routes.mapValues(PolylinePath.init)
        guard camera == .automatic, let networkRect else { return }
        camera = .rect(networkRect)
    }

    private var overlays: [LineOverlay] {
        lines
            .filter { lineFilter == nil || $0.id == lineFilter }
            .map { LineOverlay(line: $0, coordinates: routes[$0.id] ?? []) }
    }

    private var visiblePins: [StationPin] {
        stations
            .map(StationPin.init)
            .filter { pin in
                lineFilter.map {
                    pin.lineIDs.isEmpty || pin.lineIDs.contains($0)
                } ?? true
            }
    }

    private var visibleStations: [Station] {
        stations.filter { station in
            lineFilter.map { lineID in
                station.lines.contains { $0.id == lineID }
            } ?? true
        }
    }

    private var nearbyFallback: NearbyFallback? {
        let lineIDs = StationPickerSectionBuilder.lineIDs(lines)
        let nearest = NearbyCarouselBuilder.nearest(to: location.location, among: visibleStations)
        let lineID =
            lineFilter
            ?? nearest.flatMap { station in
                lineIDs.first { lineID in station.lines.contains { $0.id == lineID } }
            }
            ?? lineIDs.first
        return lines.first { $0.id == lineID }.map {
            NearbyFallback(
                lineID: $0.id,
                stations: $0.orderedStops.compactMap(\.station)
            )
        }
    }

    private var feedStatus: MapFeedStatus? {
        MapFeedStatus.resolve(isOnline: isOnline, hasLoadedTrains: hasLoadedTrains)
    }

    private var trainTracks: [TrainTrack] {
        guard let feed = realtimeFeeds.first else { return [] }
        return TrainTrackBuilder.tracks(
            trains: liveTrains.filter {
                lineFilter == nil || $0.lineID == lineFilter
            },
            lines: lines,
            paths: paths,
            fetchedAt: feed.feedTimestamp ?? feed.fetchedAt
        )
    }

    private var networkRect: MKMapRect? {
        MapCameraBuilder.networkRect(
            routes.values.flatMap(\.self) + stations.map(\.coordinate)
        )
    }

    private func showNetwork() {
        guard let networkRect else { return }
        withAnimation(reduceMotion ? nil : MapSheetMotion.camera) {
            camera = .rect(networkRect)
        }
    }

    private static let emptyTitle = LocalizedStringResource(
        "Sin datos de red",
        comment: "Mapa: estado vacío cuando no hay líneas guardadas."
    )
}

private struct LivePolling: Equatable {
    let isActive: Bool
    let isOnline: Bool
}

#if DEBUG
    #Preview("Mapa", traits: .mapSampleData) {
        @Previewable @State var request: String?
        @Previewable @State var path: [AppRoute] = []

        MapScreen(request: $request, path: $path)
            .environment(LocationViewModel.preview())
    }

    #Preview("Ficha abierta", traits: .mapSampleData) {
        @Previewable @State var request: String? = "54413"
        @Previewable @State var path: [AppRoute] = []

        MapScreen(request: $request, path: $path)
            .environment(LocationViewModel.preview())
    }
#endif
