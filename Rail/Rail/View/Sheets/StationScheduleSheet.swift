import SwiftData
import SwiftUI

struct StationScheduleSheet: View {
    let station: Station

    @Environment(\.dismiss) private var dismiss
    @Query private var networks: [TransitNetwork]

    var body: some View {
        NavigationStack {
            Group {
                if let network = networks.first {
                    StationScheduleContent(station: station, calendar: network.calendar)
                } else {
                    Self.noTrains
                }
            }
            .background(.bgPrimary)
            .navigationTitle(Self.title)
            .navigationSubtitle(station.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    static var noTrains: some View {
        CardMessage(
            LocalizedStringResource(
                "No hay trenes este día",
                comment: "Horarios: título cuando la estación no tiene salidas el día elegido."
            ),
            message: LocalizedStringResource(
                "Prueba con otro día o con otro destino.",
                comment: "Horarios: sugerencia cuando no hay salidas el día elegido."
            ),
            icon: .symbol("calendar", tint: .textTertiary)
        )
        .padding(ScreenLayout.margin)
        .frame(maxHeight: .infinity)
    }

    static let title = LocalizedStringResource(
        "Horarios",
        comment: "Horarios: título de la hoja con todas las salidas de una estación; también etiqueta del botón que la abre."
    )
}

private struct StationScheduleContent: View {
    let station: Station
    let calendar: Calendar

    @Query private var timetables: [Timetable]
    @State private var selectedDay: Date?
    @State private var filter: String?
    @State private var showsDeparted = false
    @State private var schedules: [StationLineSchedule] = []

    private var timetable: Timetable? { timetables.first }

    private var timeZone: TimeZone { calendar.timeZone }

    private var activeFilter: String? {
        filter.flatMap { id in schedules.contains { $0.id == id } ? id : nil }
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

    private func day(today: Date) -> Date? {
        selectedDay ?? days(today: today).first
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let day = day(today: context.date)
            content(day: day, now: context.date)
                .safeAreaBar(edge: .top) {
                    filters(days: days(today: context.date), selected: day, today: context.date)
                }
                .loadSchedules(
                    ScheduleRequest(stationID: station.id, timetable: timetable, serviceDay: day),
                    into: $schedules
                ) {
                    try await $0.schedules(for: $1)
                }
        }
    }

    @ViewBuilder
    private func content(day: Date?, now: Date) -> some View {
        if let day {
            let timetable = StationTimetableBuilder.timetable(
                schedules,
                filter: activeFilter,
                serviceDay: day,
                now: now,
                calendar: calendar,
                timeZone: timeZone
            )
            if timetable.isEmpty {
                StationScheduleSheet.noTrains
            } else {
                list(timetable, day: day)
            }
        } else {
            StationScheduleSheet.noTrains
        }
    }

    private func list(_ timetable: StationTimetable, day: Date) -> some View {
        let showsDeparted = showsDeparted || !timetable.hasUpcoming
        return List {
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
            if !timetable.nextDay.isEmpty {
                Section {
                    rows(timetable.nextDay)
                } header: {
                    StationSectionHeader(nextDayTitle(after: day))
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(Spacing.md)
        .contentMargins(.bottom, Spacing.xxl, for: .scrollContent)
        .id(day)
    }

    private func rows(_ rows: [StationTimetableRow], last: Bool = true) -> some View {
        ForEach(rows) { row in
            TimetableRow(row, showsSeparator: !last || row.id != rows.last?.id)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }

    private func filters(days: [Date], selected: Date?, today: Date) -> some View {
        let filters = StationTimetableBuilder.filters(schedules)
        return GlassEffectContainer(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                ServiceDayMenu(
                    days: days,
                    selection: Binding(get: { selected }, set: { selectedDay = $0 }),
                    today: today,
                    calendar: calendar
                )
                if filters.count > 1 {
                    destinationMenu(filters)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.xs)
        }
        .menuStyle(.button)
        .buttonStyle(.railGlass(.clear))
        .controlSize(.small)
    }

    private func destinationMenu(_ filters: [StationTimetableFilter]) -> some View {
        Menu {
            Picker(selection: Binding(get: { activeFilter }, set: { filter = $0 })) {
                Text(Self.allDestinations).tag(String?.none)
                ForEach(filters) { option in
                    Text(verbatim: "\(option.lineID) · \(option.destination)").tag(Optional(option.id))
                }
            } label: {
                Text(Self.destinationPickerTitle)
            }
            .pickerStyle(.inline)
        } label: {
            MenuPickerLabel(systemImage: "arrow.triangle.branch") {
                filters.first { $0.id == activeFilter }
                    .map { Text(verbatim: "\($0.lineID) · \($0.destination)") }
                    ?? Text(Self.allDestinations)
            }
        }
        .accessibilityLabel(Text(Self.destinationPickerTitle))
    }

    private func nextDayTitle(after day: Date) -> LocalizedStringResource {
        let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        return LocalizedStringResource(
            "Madrugada del \(next.formatted(ServiceDayMenu.longDayFormat(timeZone)))",
            comment: "Horarios: cabecera de los trenes de después de medianoche, que cuentan como parte del día elegido; por ejemplo «Madrugada del sábado 27»."
        )
    }

    private static let allDestinations = LocalizedStringResource(
        "Todos los destinos",
        comment: "Horarios: filtro que muestra las salidas hacia todos los destinos."
    )

    private static let destinationPickerTitle = LocalizedStringResource(
        "Destino",
        comment: "Horarios: título del menú para filtrar las salidas por línea y destino."
    )
}

#if DEBUG
    #Preview(traits: .stationTimetableSampleData) {
        @Previewable @Query(filter: #Predicate<Station> { $0.id == "54413" }) var stations: [Station]
        if let station = stations.first {
            StationScheduleSheet(station: station)
        }
    }
#endif
