import SwiftUI

struct DepartureList: View {
    private let departures: NextTrainsDepartures

    init(_ departures: NextTrainsDepartures) {
        self.departures = departures
    }

    var body: some View {
        switch departures {
        case .upcoming(let rows):
            VStack(spacing: Spacing.xs) {
                ForEach(rows) { row in
                    DepartureRow(
                        row.line,
                        color: Color(hex: row.colorHex),
                        to: row.destination,
                        time: row.time,
                        showsSeparator: row.id != rows.last?.id
                    )
                }
            }
        case .loading:
            VStack(spacing: Spacing.xs) {
                DepartureRow(
                    "C-1",
                    color: .fillTertiary,
                    to: "Málaga Centro Alameda",
                    time: "00:00"
                )
                DepartureRow(
                    "C-1",
                    color: .fillTertiary,
                    to: "Fuengirola",
                    time: "00:00",
                    showsSeparator: false
                )
            }
            .redacted(reason: .placeholder)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                Text(
                    "Cargando próximos trenes",
                    comment:
                        "Tarjeta de próximos trenes: descripción para VoiceOver mientras se calculan las salidas."
                )
            )
        case .finished(let firstTomorrow):
            CardMessage(
                LocalizedStringResource(
                    "No quedan trenes hoy",
                    comment:
                        "Tarjeta de próximos trenes: título cuando ya no hay más salidas en el día."
                ),
                message: firstTomorrow.map { time in
                    LocalizedStringResource(
                        "Primera salida mañana a las \(time)",
                        comment:
                            "Tarjeta de próximos trenes: hora de la primera salida del día siguiente, por ejemplo «05:40»."
                    )
                },
                icon: .symbol("clock", tint: .textTertiary),
                prominence: .compact
            )
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Spacing.xxl) {
        DepartureList(
            .upcoming([
                NextTrainsDeparture(id: "1", line: "C-1", colorHex: "DA291C", destination: "Fuengirola", time: "10:12"),
                NextTrainsDeparture(id: "2", line: "C-2", colorHex: "0057A8", destination: "Álora", time: "10:20"),
            ])
        )
        DepartureList(.loading)
        DepartureList(.finished(firstTomorrow: "05:40"))
    }
    .cardSurface()
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
}
#endif
