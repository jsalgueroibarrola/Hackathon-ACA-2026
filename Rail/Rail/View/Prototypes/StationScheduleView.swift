import SwiftUI

struct StationScheduleView: View {
    let schedule: StationLineSchedule
    let stationName: String
    let timeFormat: Date.FormatStyle
    let now: Date

    @State private var showsPast = false

    private var upcoming: [StationDeparture] { schedule.upcoming(from: now) }

    private var past: [StationDeparture] {
        Array(schedule.departures.prefix(schedule.departures.count - upcoming.count))
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: Spacing.md) {
                    LineBadge(schedule.lineID, color: Color(hex: schedule.colorHex), scale: .large)
                    Text(schedule.lineName)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }

            Section("Próximas salidas") {
                if upcoming.isEmpty {
                    Text("Sin más trenes hoy")
                        .foregroundStyle(.textSecondary)
                } else {
                    ForEach(upcoming) { departure in
                        ScheduleDepartureRow(departure: departure, timeFormat: timeFormat, isPast: false)
                    }
                }
            }

            if !past.isEmpty {
                Section("Ya han salido", isExpanded: $showsPast) {
                    ForEach(past) { departure in
                        ScheduleDepartureRow(departure: departure, timeFormat: timeFormat, isPast: true)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(Text("Hacia \(schedule.destination)"))
        .navigationSubtitle(stationName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ScheduleDepartureRow: View {
    let departure: StationDeparture
    let timeFormat: Date.FormatStyle
    let isPast: Bool

    var body: some View {
        LabeledContent {
            Text("Tren \(departure.train)")
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.textTertiary)
        } label: {
            Text(departure.date, format: timeFormat)
                .font(.timeDeparture)
                .foregroundStyle(isPast ? .textTertiary : .textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let now = Date(timeIntervalSince1970: 1_790_000_000)

    NavigationStack {
        StationScheduleView(
            schedule: StationLineSchedule(
                lineID: "C1",
                lineName: "Málaga-Centro Alameda – Fuengirola",
                colorHex: "DA291C",
                direction: .outbound,
                destination: "Fuengirola",
                departures: (0..<12).map { index in
                    StationDeparture(
                        id: "C1-\(index)",
                        train: "1\(index)04",
                        date: now.addingTimeInterval(Double(index - 4) * 1_200)
                    )
                }
            ),
            stationName: "Málaga-Centro Alameda",
            timeFormat: .departureTime(in: .gmt),
            now: now
        )
    }
}
