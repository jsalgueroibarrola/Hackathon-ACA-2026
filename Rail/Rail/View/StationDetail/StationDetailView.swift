import MapKit
import SwiftData
import SwiftUI

struct StationDetailView: View {
    let station: Station

    @Environment(LocationViewModel.self) private var location
    @Environment(FavoritesViewModel.self) private var favoritesModel
    @Query private var favorites: [FavoriteStation]
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @State private var schedules: NextTrainsSchedules?
    @State private var isShowingSchedule = false

    private static let mapHeight: CGFloat = 160
    private static let mapSpan: CLLocationDistance = 700
    private static let visibleDepartures = 4

    init(station: Station) {
        self.station = station
        let stationID = station.id
        _favorites = Query(filter: #Predicate<FavoriteStation> { $0.stationID == stationID })
    }

    private var timetable: Timetable? { timetables.first }

    private var lines: [Line] {
        station.lines.sortedByID
    }

    private var distance: LocalizedStringResource? {
        location.distance(to: station.coordinate)
            .flatMap { $0 <= NextTrainsCardStateBuilder.nearbyRadius ? $0 : nil }
            .map { .distanceAway($0.distanceLabel) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: ScreenLayout.gutter) {
                header
                nextTrains
                StationTravelCard(station: station)
                accessibility
                connections
            }
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.lg)
            .frame(maxWidth: ScreenLayout.maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .background(.bgSecondary)
        .navigationTitle(station.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(StationScheduleSheet.title, systemImage: "calendar") {
                    isShowingSchedule = true
                }
                Toggle(isOn: favoritesModel.binding(for: station.id, isFavorite: !favorites.isEmpty)) {}
                    .toggleStyle(.favorite)
            }
        }
        .sheet(isPresented: $isShowingSchedule) {
            StationScheduleSheet(station: station)
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            map
            VStack(alignment: .leading, spacing: Spacing.md) {
                StationHeader(station.name, subtitle: distance)
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(lines) { line in
                        HStack(spacing: Spacing.sm) {
                            LineBadge(line.id, color: Color(hex: line.colorHex))
                            Text(verbatim: line.name)
                                .font(.subheadline)
                                .foregroundStyle(.textSecondary)
                                .lineLimit(2)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                Button {
                    station.openDirections()
                } label: {
                    Label(Self.directionsTitle, systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.railGlass(.tinted))
                .accessibilityHint(Text(Self.directionsHint))
            }
            .padding(Spacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bgPrimary)
        .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
    }

    private var map: some View {
        Map(
            initialPosition: .region(
                MKCoordinateRegion(
                    center: station.coordinate,
                    latitudinalMeters: Self.mapSpan,
                    longitudinalMeters: Self.mapSpan
                )
            ),
            interactionModes: []
        ) {
            Marker(station.name, systemImage: "tram.fill", coordinate: station.coordinate)
                .tint(.brandPrimary)
        }
        .frame(height: Self.mapHeight)
        .accessibilityHidden(true)
    }

    private var nextTrains: some View {
        TimelineView(.everyMinute) { context in
            VStack(alignment: .leading, spacing: Spacing.xs) {
                CardSectionHeader(Self.nextTrainsTitle, systemImage: "clock") {
                    Button(Self.fullScheduleTitle) {
                        isShowingSchedule = true
                    }
                    .buttonStyle(.rail(.borderless))
                    .controlSize(.small)
                }
                DepartureList(departures(at: context.date))
            }
            .cardSurface()
            .loadSchedules(scheduleRequest(at: context.date), into: $schedules) {
                try await $0.nextTrains(for: $1)
            }
        }
    }

    @ViewBuilder
    private var accessibility: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            CardSectionHeader(Self.accessibilityTitle, systemImage: "figure.roll")
            if station.isAccessible == nil && station.hasElevator == nil {
                StationFeatureRow(
                    Self.accessibilityUnknown,
                    systemImage: "questionmark.circle",
                    isKnown: false
                )
            }
            if station.isAccessible == true {
                StationFeatureRow(Self.reducedMobility, systemImage: StationAccessibilitySymbol.reducedMobility)
            }
            if station.hasElevator == true {
                StationFeatureRow(Self.elevator, systemImage: StationAccessibilitySymbol.elevator)
            }
        }
        .cardSurface()
    }

    @ViewBuilder
    private var connections: some View {
        if !station.connections.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                CardSectionHeader(Self.connectionsTitle, systemImage: "arrow.triangle.branch")
                ForEach(station.connections, id: \.self) { connection in
                    StationFeatureRow(connection.displayName, systemImage: connection.symbolName)
                }
            }
            .cardSurface()
        }
    }

    private func departures(at date: Date) -> NextTrainsDepartures {
        guard timetable != nil else { return .finished(firstTomorrow: nil) }
        return schedules.map {
            NextTrainsCardStateBuilder.departures(
                from: $0,
                now: date,
                limit: Self.visibleDepartures
            )
        } ?? .loading
    }

    private func scheduleRequest(at date: Date) -> ScheduleRequest? {
        ScheduleRequest(
            stationID: station.id,
            timetable: timetable,
            network: networks.first,
            at: date
        )
    }

    private static let directionsTitle = LocalizedStringResource(
        "Iniciar ruta",
        comment: "Detalle de estación: botón principal que abre la ruta hasta la estación en Apple Maps."
    )

    private static let directionsHint = LocalizedStringResource(
        "Abre la ruta en Mapas",
        comment: "Detalle de estación: pista de VoiceOver del botón «Cómo llegar»."
    )

    private static let nextTrainsTitle = LocalizedStringResource(
        "Próximos trenes",
        comment: "Detalle de estación: cabecera de la tarjeta con las próximas salidas."
    )

    private static let fullScheduleTitle = LocalizedStringResource(
        "Ver horarios",
        comment: "Detalle de estación: botón de la tarjeta de próximos trenes que abre la hoja de horarios."
    )

    private static let accessibilityTitle = LocalizedStringResource(
        "Accesibilidad",
        comment: "Detalle de estación: cabecera de la tarjeta con las prestaciones de accesibilidad."
    )

    private static let reducedMobility = LocalizedStringResource(
        "Adaptada para movilidad reducida",
        comment: "Detalle de estación: la estación es accesible para personas con movilidad reducida."
    )

    private static let elevator = LocalizedStringResource(
        "Con ascensor",
        comment: "Detalle de estación: la estación tiene ascensor."
    )

    private static let accessibilityUnknown = LocalizedStringResource(
        "Renfe no informa de la accesibilidad de esta estación",
        comment: "Detalle de estación: no hay datos de accesibilidad para la estación."
    )

    private static let connectionsTitle = LocalizedStringResource(
        "Conexiones",
        comment: "Detalle de estación: cabecera de la tarjeta con los otros transportes con los que enlaza."
    )
}

#if DEBUG
    #Preview("Estación", traits: .stationTimetableSampleData) {
        NavigationStack {
            StationDestination(stationID: "54413")
        }
        .environment(LocationViewModel.preview())
    }

    #Preview("Sin permiso", traits: .stationTimetableSampleData) {
        NavigationStack {
            StationDestination(stationID: "54413")
        }
        .environment(LocationViewModel.preview(authorization: .notDetermined))
    }

    #Preview("Sin tiempos", traits: .stationTimetableSampleData) {
        NavigationStack {
            StationDestination(stationID: "54413")
        }
        .environment(LocationViewModel.preview())
        .environment(\.routeEstimates, PreviewRouteService(values: [:]))
    }

    #Preview("Modo oscuro", traits: .stationTimetableSampleData) {
        NavigationStack {
            StationDestination(stationID: "54404")
        }
        .environment(LocationViewModel.preview(authorization: .denied))
        .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type", traits: .stationTimetableSampleData) {
        NavigationStack {
            StationDestination(stationID: "54413")
        }
        .environment(LocationViewModel.preview())
        .dynamicTypeSize(.accessibility2)
    }
#endif
