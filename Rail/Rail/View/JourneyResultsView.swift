import SwiftData
import SwiftUI

struct JourneyResultsView: View {
    let query: JourneyQuery

    @Environment(RecentJourneysViewModel.self) private var recents
    @Query private var networks: [TransitNetwork]
    @State private var isReversed = false

    private var current: JourneyQuery {
        isReversed ? query.reversed : query
    }

    var body: some View {
        Group {
            if let network = networks.first {
                JourneyResultsContent(
                    query: current,
                    calendar: network.calendar,
                    onSwap: { isReversed.toggle() }
                )
            } else {
                StationScheduleSheet.noTrains
            }
        }
        .background(.bgPrimary)
        .navigationTitle(Self.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .task(id: [current.originID, current.destinationID]) {
            recents.record(originID: current.originID, destinationID: current.destinationID)
        }
    }

    static let title = LocalizedStringResource(
        "Trayecto",
        comment: "Trayectos: título de la pantalla con los trenes entre dos estaciones."
    )
}

private struct LoadedJourneys: Sendable {
    let request: JourneyRequest
    let journeys: [Journey]
}

private struct JourneyResultsContent: View {
    let query: JourneyQuery
    let calendar: Calendar
    let onSwap: () -> Void

    @Query private var timetables: [Timetable]
    @Query private var stations: [Station]
    @State private var selectedDay: Date?
    @State private var showsDeparted = false
    @State private var loaded: LoadedJourneys?

    private var timetable: Timetable? { timetables.first }

    private var timeZone: TimeZone { calendar.timeZone }

    private func name(_ stationID: String) -> String {
        stations.first { $0.id == stationID }?.name ?? ""
    }

    private func days(today: Date) -> [Date] {
        timetable.map {
            StationTimetableBuilder.days(
                from: $0.startDay,
                through: $0.endDay,
                today: today,
                calendar: calendar
            )
        } ?? []
    }

    private func day(in days: [Date]) -> Date? {
        [selectedDay, query.day]
            .compactMap(\.self)
            .first { days.contains($0) }
            ?? days.first
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let days = days(today: context.date)
            let day = day(in: days)
            let request = JourneyRequest(
                originID: query.originID,
                destinationID: query.destinationID,
                timetable: timetable,
                serviceDay: day
            )
            list(request: request, now: context.date)
                .safeAreaBar(edge: .top) {
                    dayBar(days: days, selected: day, today: context.date)
                }
                .loadSchedules(request, into: $loaded) {
                    LoadedJourneys(request: $1, journeys: try await $0.journeys(for: $1))
                }
        }
    }

    private func list(request: JourneyRequest?, now: Date) -> some View {
        let journeys = loaded.flatMap { $0.request == request ? $0.journeys : nil }
        return List {
            JourneyRouteHeader(
                originName: name(query.originID),
                destinationName: name(query.destinationID),
                summary: journeys.map(JourneyTimetableBuilder.summary),
                onSwap: onSwap
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

            switch (request, journeys) {
            case (.some(let request), .some(let journeys)):
                rows(
                    JourneyTimetableBuilder.timetable(
                        journeys,
                        serviceDay: request.serviceDay,
                        now: now,
                        calendar: calendar,
                        timeZone: timeZone
                    ),
                    day: request.serviceDay
                )
            case (.some, .none):
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.xxxxl)
                    .listRowSeparator(.hidden)
            case (.none, _):
                noTrains
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(Spacing.md)
        .contentMargins(.bottom, Spacing.xxl, for: .scrollContent)
    }

    @ViewBuilder
    private func rows(_ timetable: JourneyTimetable, day: Date) -> some View {
        if timetable.isEmpty {
            noTrains
        } else {
            let showsDeparted = showsDeparted || !timetable.hasUpcoming
            Section {
                if !timetable.departed.isEmpty && timetable.hasUpcoming {
                    DepartedToggleRow(count: timetable.departed.count, isExpanded: showsDeparted) {
                        withAnimation(.snappy) {
                            self.showsDeparted.toggle()
                        }
                    }
                }
                if showsDeparted {
                    rows(timetable.departed, last: timetable.upcoming.isEmpty)
                }
                rows(timetable.upcoming)
            }
            if !timetable.nextDay.isEmpty {
                Section {
                    rows(timetable.nextDay)
                } header: {
                    StationSectionHeader(nextDayTitle(after: day))
                }
            }
        }
    }

    private func rows(_ rows: [JourneyTimetableRow], last: Bool = true) -> some View {
        ForEach(rows) { row in
            JourneyRow(row, showsSeparator: !last || row.id != rows.last?.id)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }

    private var noTrains: some View {
        StationScheduleSheet.noTrains
            .listRowSeparator(.hidden)
    }

    private func dayBar(days: [Date], selected: Date?, today: Date) -> some View {
        GlassEffectContainer(spacing: Spacing.sm) {
            ServiceDayMenu(
                days: days,
                selection: Binding(get: { selected }, set: { selectedDay = $0 }),
                today: today,
                calendar: calendar
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.xs)
        }
        .menuStyle(.button)
        .buttonStyle(.railGlass(.clear))
        .controlSize(.small)
    }

    private func nextDayTitle(after day: Date) -> LocalizedStringResource {
        let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        return LocalizedStringResource(
            "Madrugada del \(next.formatted(ServiceDayMenu.longDayFormat(timeZone)))",
            comment: "Horarios: cabecera de los trenes de después de medianoche, que cuentan como parte del día elegido; por ejemplo «Madrugada del sábado 27»."
        )
    }
}

#if DEBUG
    #Preview("Directo", traits: .stationTimetableSampleData) {
        NavigationStack {
            JourneyResultsView(
                query: JourneyQuery(originID: "54413", destinationID: "54100", day: nil)
            )
        }
    }

    #Preview("Con transbordo", traits: .stationTimetableSampleData) {
        NavigationStack {
            JourneyResultsView(
                query: JourneyQuery(originID: "54100", destinationID: "54503", day: nil)
            )
        }
    }

    #Preview("Modo oscuro", traits: .stationTimetableSampleData) {
        NavigationStack {
            JourneyResultsView(
                query: JourneyQuery(originID: "54413", destinationID: "54100", day: nil)
            )
        }
        .preferredColorScheme(.dark)
    }
#endif
