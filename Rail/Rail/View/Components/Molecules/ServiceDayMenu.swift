import SwiftUI

struct ServiceDayMenu: View {
    private let days: [Date]
    @Binding private var selection: Date?
    private let today: Date
    private let calendar: Calendar

    init(days: [Date], selection: Binding<Date?>, today: Date, calendar: Calendar) {
        self.days = days
        _selection = selection
        self.today = today
        self.calendar = calendar
    }

    private var timeZone: TimeZone { calendar.timeZone }

    var body: some View {
        Menu {
            Picker(selection: $selection) {
                ForEach(days, id: \.self) { day in
                    menuText(day).tag(Optional(day))
                }
            } label: {
                Text(Self.title)
            }
            .pickerStyle(.inline)
        } label: {
            MenuPickerLabel(systemImage: "calendar") {
                selection.map(chipText) ?? Text(Self.title)
            }
        }
        .fixedSize()
        .accessibilityLabel(Text(Self.title))
    }

    private func offset(_ day: Date) -> Int? {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: day).day
    }

    private func chipText(_ day: Date) -> Text {
        switch offset(day) {
        case 0:
            Text("Hoy", comment: "Horarios: chip del día de hoy.")
        case 1:
            Text("Mañana", comment: "Horarios: chip del día de mañana.")
        default:
            Text(verbatim: day.formatted(Date.FormatStyle(timeZone: timeZone).weekday(.abbreviated).day()))
        }
    }

    private func menuText(_ day: Date) -> Text {
        let date = day.formatted(Self.longDayFormat(timeZone))
        return switch offset(day) {
        case 0:
            Text("Hoy, \(date)", comment: "Horarios: opción del menú de días para hoy; por ejemplo «Hoy, jueves 25».")
        case 1:
            Text("Mañana, \(date)", comment: "Horarios: opción del menú de días para mañana; por ejemplo «Mañana, viernes 26».")
        default:
            Text(verbatim: date)
        }
    }

    static func longDayFormat(_ timeZone: TimeZone) -> Date.FormatStyle {
        Date.FormatStyle(timeZone: timeZone).weekday(.wide).day()
    }

    static let title = LocalizedStringResource(
        "Día",
        comment: "Horarios: título del menú para elegir el día del horario."
    )
}

struct MenuPickerLabel: View {
    private let systemImage: String
    private let title: Text

    init(systemImage: String, @ViewBuilder title: () -> Text) {
        self.systemImage = systemImage
        self.title = title()
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: systemImage)
            title
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.textTertiary)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection: Date? = Calendar.current.startOfDay(for: .now)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    VStack(spacing: Spacing.lg) {
        ServiceDayMenu(
            days: (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: today) },
            selection: $selection,
            today: today,
            calendar: calendar
        )
        .buttonStyle(.railGlass(.clear))
        ServiceDayMenu(
            days: (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: today) },
            selection: $selection,
            today: today,
            calendar: calendar
        )
        .buttonStyle(.rail(.bordered))
    }
    .menuStyle(.button)
    .controlSize(.small)
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}
#endif
