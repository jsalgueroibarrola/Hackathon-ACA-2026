import SwiftData
import SwiftUI

struct StationScheduleSheet: View {
    let station: Station

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var networks: [TransitNetwork]
    @Query private var timetables: [Timetable]
    @State private var selectedDay: Date?
    @State private var filter: String?
    @State private var showsDeparted = false
    @State private var schedules: [StationLineSchedule] = []

    private struct ScheduleRequest: Equatable {
        let timetableKey: String
        let day: Date
    }

    private var timetable: Timetable? { timetables.first }

    private var calendar: Calendar { networks.first?.calendar ?? .autoupdatingCurrent }

    private var timeZone: TimeZone { networks.first?.timeZone ?? .autoupdatingCurrent }

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
        NavigationStack {
            TimelineView(.everyMinute) { context in
                let day = day(today: context.date)
                content(day: day, now: context.date)
                    .safeAreaBar(edge: .top) {
                        filters(days: days(today: context.date), selected: day, today: context.date)
                    }
                    .task(id: day.map { ScheduleRequest(timetableKey: timetable?.etag ?? timetable?.version ?? "", day: $0) }) {
                        load(day)
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

    @ViewBuilder
    private func content(day: Date?, now: Date) -> some View {
        if let day {
            let timetable = StationTimetableBuilder.timetable(
                schedules,
                filter: filter,
                serviceDay: day,
                now: now,
                calendar: calendar,
                timeZone: timeZone
            )
            if timetable.isEmpty {
                noTrains
            } else {
                list(timetable, day: day)
            }
        } else {
            noTrains
        }
    }

    private func list(_ timetable: StationTimetable, day: Date) -> some View {
        let showsDeparted = showsDeparted || !timetable.hasUpcoming
        return List {
            if !timetable.departed.isEmpty && timetable.hasUpcoming {
                departedToggle(count: timetable.departed.count, isExpanded: showsDeparted)
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

    private func departedToggle(count: Int, isExpanded: Bool) -> some View {
        Button {
            withAnimation(.snappy) {
                showsDeparted.toggle()
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.textTertiary)
                Text(
                    isExpanded
                        ? LocalizedStringResource(
                            "Ocultar salidas anteriores",
                            comment: "Horarios: botón que oculta los trenes que ya han salido hoy."
                        )
                        : LocalizedStringResource(
                            "Ver \(count) salidas anteriores",
                            comment: "Horarios: botón que muestra los trenes que ya han salido hoy; el número es cuántos."
                        )
                )
                .foregroundStyle(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .font(.subheadline)
            .padding(.horizontal, ScreenLayout.margin)
            .frame(minHeight: Size.rowMin)
            .background(.bgSecondary)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }

    private func filters(days: [Date], selected: Date?, today: Date) -> some View {
        let filters = StationTimetableBuilder.filters(schedules)
        return GlassEffectContainer(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                dayMenu(days: days, selected: selected, today: today)
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

    private func dayMenu(days: [Date], selected: Date?, today: Date) -> some View {
        Menu {
            Picker(
                selection: Binding(get: { selected }, set: { selectedDay = $0 })
            ) {
                ForEach(days, id: \.self) { day in
                    dayMenuLabel(day, today: today).tag(Optional(day))
                }
            } label: {
                Text(Self.dayPickerTitle)
            }
            .pickerStyle(.inline)
        } label: {
            menuLabel(systemImage: "calendar") {
                selected.map { dayLabel($0, today: today) } ?? Text(Self.dayPickerTitle)
            }
        }
        .fixedSize()
        .accessibilityLabel(Text(Self.dayPickerTitle))
    }

    private func destinationMenu(_ filters: [StationTimetableFilter]) -> some View {
        Menu {
            Picker(selection: $filter) {
                Text(Self.allDestinations).tag(String?.none)
                ForEach(filters) { option in
                    Text(verbatim: "\(option.lineID) · \(option.destination)").tag(Optional(option.id))
                }
            } label: {
                Text(Self.destinationPickerTitle)
            }
            .pickerStyle(.inline)
        } label: {
            menuLabel(systemImage: "arrow.triangle.branch") {
                filters.first { $0.id == filter }
                    .map { Text(verbatim: "\($0.lineID) · \($0.destination)") }
                    ?? Text(Self.allDestinations)
            }
        }
        .accessibilityLabel(Text(Self.destinationPickerTitle))
    }

    private func menuLabel(systemImage: String, @ViewBuilder title: () -> Text) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: systemImage)
            title()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.textTertiary)
        }
    }

    private var noTrains: some View {
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

    private func load(_ day: Date?) {
        schedules =
            day.flatMap { day in
                timetable.map {
                    StationScheduleBuilder.schedules(
                        for: station,
                        timetable: $0,
                        day: day,
                        calendar: calendar,
                        context: modelContext
                    )
                }
            } ?? []
        if let filter, !schedules.contains(where: { $0.id == filter }) {
            self.filter = nil
        }
    }

    private func dayLabel(_ day: Date, today: Date) -> Text {
        let offset = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: today),
            to: day
        ).day
        return switch offset {
        case 0:
            Text("Hoy", comment: "Horarios: chip del día de hoy.")
        case 1:
            Text("Mañana", comment: "Horarios: chip del día de mañana.")
        default:
            Text(verbatim: day.formatted(Self.dayFormat(timeZone)))
        }
    }

    private func dayMenuLabel(_ day: Date, today: Date) -> Text {
        let date = day.formatted(Self.longDayFormat(timeZone))
        return switch calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: day).day {
        case 0:
            Text("Hoy, \(date)", comment: "Horarios: opción del menú de días para hoy; por ejemplo «Hoy, jueves 25».")
        case 1:
            Text("Mañana, \(date)", comment: "Horarios: opción del menú de días para mañana; por ejemplo «Mañana, viernes 26».")
        default:
            Text(verbatim: date)
        }
    }

    private func nextDayTitle(after day: Date) -> LocalizedStringResource {
        let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        return LocalizedStringResource(
            "Madrugada del \(next.formatted(Self.longDayFormat(timeZone)))",
            comment: "Horarios: cabecera de los trenes de después de medianoche, que cuentan como parte del día elegido; por ejemplo «Madrugada del sábado 27»."
        )
    }

    private static func dayFormat(_ timeZone: TimeZone) -> Date.FormatStyle {
        Date.FormatStyle(timeZone: timeZone).weekday(.abbreviated).day()
    }

    private static func longDayFormat(_ timeZone: TimeZone) -> Date.FormatStyle {
        Date.FormatStyle(timeZone: timeZone).weekday(.wide).day()
    }

    static let title = LocalizedStringResource(
        "Horarios",
        comment: "Horarios: título de la hoja con todas las salidas de una estación; también etiqueta del botón que la abre."
    )

    private static let allDestinations = LocalizedStringResource(
        "Todos los destinos",
        comment: "Horarios: filtro que muestra las salidas hacia todos los destinos."
    )

    private static let dayPickerTitle = LocalizedStringResource(
        "Día",
        comment: "Horarios: título del menú para elegir el día del horario."
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
