import SwiftData
import SwiftUI

struct StationSummary: View {
    let station: Station

    @Environment(LocationViewModel.self) private var location
    @State private var walking: RouteEstimates?
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @State private var schedules: NextTrainsSchedules?
    @State private var isShowingSchedule = false

    private var lines: [Line] {
        station.lines.sorted {
            $0.id.localizedStandardCompare($1.id) == .orderedAscending
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            overview
            nextTrains
            actions
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.bottom, Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $isShowingSchedule) {
            StationScheduleSheet(station: station)
        }
        .loadRouteEstimates(walkingRequest, into: $walking)
    }

    private var overview: some View {
        HStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                ForEach(lines) { line in
                    LineBadge(line.id, color: Color(hex: line.colorHex))
                }
            }
            proximityView
        }
        .animation(.smooth, value: proximity)
    }

    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.sm) {
                actionButtons
            }
            VStack(spacing: Spacing.sm) {
                actionButtons
            }
        }
        .controlSize(.large)
    }

    @ViewBuilder
    private var actionButtons: some View {
        Button {
                station.openDirections()
            } label: {
            Label(
                Self.directionsTitle,
                systemImage: "arrow.triangle.turn.up.right.diamond.fill"
            )
            .lineLimit(1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.rail(.prominent))
        .accessibilityHint(Text(Self.directionsHint))

        NavigationLink(value: AppRoute.station(id: station.id)) {
            Label(Self.detailTitle, systemImage: "info.circle")
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.railGlass(.clear))
    }

    @ViewBuilder
    private var proximityView: some View {
        switch proximity {
        case .permissionNeeded:
            Button(Self.allowLocationTitle, systemImage: "location") {
                location.requestAccess()
            }
            .buttonStyle(.rail(.borderless))
            .controlSize(.small)
        case .locating:
            Label(Self.locatingTitle, systemImage: "location")
                .font(.subheadline)
                .foregroundStyle(.textTertiary)
        case .away(let away):
            Label(away.subtitle, systemImage: away.symbolName)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .contentTransition(.numericText())
        case .unknown:
            EmptyView()
        }
    }

    private var nextTrains: some View {
        TimelineView(.everyMinute) { context in
            VStack(alignment: .leading, spacing: Spacing.xs) {
                CardSectionHeader(Self.nextTrainsTitle, systemImage: "clock") {
                    Button(Self.allSchedulesTitle) {
                        isShowingSchedule = true
                    }
                    .buttonStyle(.rail(.borderless))
                    .controlSize(.small)
                }
                DepartureList(departures(at: context.date))
            }
            .cardSurface(.translucent)
            .loadSchedules(scheduleRequest(at: context.date), into: $schedules)
            {
                try await $0.nextTrains(for: $1)
            }
        }
    }

    private func departures(at date: Date) -> NextTrainsDepartures {
        guard timetables.first != nil else {
            return .finished(firstTomorrow: nil)
        }
        return schedules.flatMap {
            $0.stationID == station.id
                ? NextTrainsCardStateBuilder.departures(
                    from: $0,
                    now: date,
                    limit: Self.visibleDepartures
                )
                : nil
        } ?? .loading
    }

    private var walkingRequest: RouteEstimateRequest? {
        StationSummaryBuilder.walkingRequest(
            from: location.location,
            to: station
        )
    }

    private var proximity: StationProximity {
        StationSummaryBuilder.proximity(
            authorization: location.authorization,
            distance: location.distance(to: station.coordinate),
            hasLocationFailed: location.hasLocationFailed,
            walking: walking?.estimate(.walking, to: station.id)
        )
    }

    private func scheduleRequest(at date: Date) -> ScheduleRequest? {
        ScheduleRequest(
            stationID: station.id,
            timetable: timetables.first,
            network: networks.first,
            at: date
        )
    }

    private static let visibleDepartures = 3

    private static let nextTrainsTitle = LocalizedStringResource(
        "Próximos trenes",
        comment:
            "Detalle de estación: cabecera de la tarjeta con las próximas salidas."
    )

    private static let allSchedulesTitle = LocalizedStringResource(
        "Ver todos los horarios",
        comment:
            "Mapa, ficha de estación: botón de la tarjeta de próximos trenes que abre la hoja con todos los horarios de la estación."
    )

    private static let allowLocationTitle = LocalizedStringResource(
        "Permitir ubicación",
        comment:
            "Mapa, ficha de estación: botón que pide el permiso de ubicación para mostrar cuánto se tarda a pie."
    )

    private static let locatingTitle = LocalizedStringResource(
        "Buscando tu ubicación…",
        comment:
            "Mapa, ficha de estación: texto mientras se obtiene la ubicación del usuario."
    )

    private static let directionsTitle = LocalizedStringResource(
        "Cómo llegar",
        comment:
            "Mapa, ficha de estación: botón que abre la ruta hasta la estación en Apple Maps."
    )

    private static let directionsHint = LocalizedStringResource(
        "Abre la ruta en Mapas",
        comment:
            "Detalle de estación: pista de VoiceOver del botón «Cómo llegar»."
    )

    private static let detailTitle = LocalizedStringResource(
        "Ver estación completa",
        comment:
            "Mapa, ficha de estación: enlace que abre la pantalla completa de la estación."
    )
}

extension NextTrainsProximity {
    fileprivate var symbolName: String {
        switch self {
        case .walking: "figure.walk"
        case .distance: "location"
        case .saved: "house"
        }
    }
}
