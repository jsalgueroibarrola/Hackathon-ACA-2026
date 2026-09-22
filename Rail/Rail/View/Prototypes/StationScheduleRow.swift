import SwiftUI

struct StationScheduleRow: View {
    let schedule: StationLineSchedule
    let now: Date
    let timeFormat: Date.FormatStyle

    private static let visibleDepartures = 3

    private var next: [StationDeparture] {
        Array(schedule.upcoming(from: now).prefix(Self.visibleDepartures))
    }

    private var spokenTimes: String {
        next.map { timeFormat.format($0.date) }.formatted(.list(type: .and))
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
            LineBadge(schedule.lineID, color: Color(hex: schedule.colorHex))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Hacia \(schedule.destination)")
                    .font(.bodyEmphasized)
                    .foregroundStyle(.textPrimary)

                if next.isEmpty {
                    Text("Sin más trenes hoy")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: Spacing.md) { times }
                        VStack(alignment: .leading, spacing: Spacing.xxs) { times }
                    }
                }
            }
        }
        .padding(.vertical, Spacing.xxs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            next.isEmpty
                ? Text("Línea \(schedule.lineID) hacia \(schedule.destination). Sin más trenes hoy")
                : Text("Línea \(schedule.lineID) hacia \(schedule.destination). Próximas salidas: \(spokenTimes)")
        )
    }

    @ViewBuilder
    private var times: some View {
        ForEach(next) { departure in
            Text(departure.date, format: timeFormat)
                .font(.timeDeparture)
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview("Próximas salidas") {
    let now = Date(timeIntervalSince1970: 1_790_000_000)

    List {
        StationScheduleRow(
            schedule: StationLineSchedule(
                lineID: "C1",
                lineName: "Málaga-Centro Alameda – Fuengirola",
                colorHex: "DA291C",
                direction: .outbound,
                destination: "Fuengirola",
                departures: (0..<6).map { index in
                    StationDeparture(
                        id: "C1-\(index)",
                        train: "1\(index)04",
                        date: now.addingTimeInterval(Double(index) * 1_200)
                    )
                }
            ),
            now: now,
            timeFormat: .departureTime(in: .gmt)
        )

        StationScheduleRow(
            schedule: StationLineSchedule(
                lineID: "C2",
                lineName: "Málaga-Centro Alameda – Álora",
                colorHex: "0057A8",
                direction: .inbound,
                destination: "Álora",
                departures: []
            ),
            now: now,
            timeFormat: .departureTime(in: .gmt)
        )
    }
}
