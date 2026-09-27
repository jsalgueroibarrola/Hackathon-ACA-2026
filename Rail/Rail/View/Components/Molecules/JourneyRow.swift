import SwiftUI

struct JourneyRow: View {
    private let row: JourneyTimetableRow
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ row: JourneyTimetableRow, showsSeparator: Bool = true) {
        self.row = row
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                times
                Spacer(minLength: Spacing.sm)
                duration
            }
            layout {
                HStack(spacing: Spacing.xs) {
                    badges
                    kind
                }
                if !dynamicTypeSize.isAccessibilitySize {
                    Spacer(minLength: Spacing.sm)
                }
                countdown
            }
            transfer
            train
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity, minHeight: Size.rowMin, alignment: .leading)
        .background {
            if row.status == .next {
                Rectangle().fill(.brandPrimarySubtle)
            }
        }
        .overlay(alignment: .leading) {
            if row.status == .next {
                Rectangle()
                    .fill(.brandPrimary)
                    .frame(width: Spacing.xs)
            }
        }
        .overlay(alignment: .bottom) {
            if showsSeparator && row.status != .next {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
                    .padding(.leading, ScreenLayout.margin)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
            : AnyLayout(HStackLayout(spacing: Spacing.sm))
    }

    private var primaryStyle: Color { row.isPast ? .textTertiary : .textPrimary }

    private var times: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
            Text(verbatim: row.departure)
                .font(.timeDepartureLarge)
                .foregroundStyle(primaryStyle)
            Image(systemName: "arrow.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
            Text(verbatim: row.arrival)
                .font(.timeDepartureLarge)
                .foregroundStyle(row.isPast ? .textTertiary : .textSecondary)
        }
    }

    private var duration: some View {
        Text(verbatim: Self.durationText(row.durationMinutes))
            .font(.subheadlineEmphasized)
            .monospacedDigit()
            .foregroundStyle(row.isPast ? .textTertiary : .textSecondary)
    }

    private var badges: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(Array(row.lines.enumerated()), id: \.element.id) { offset, line in
                if offset > 0 {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.textTertiary)
                }
                LineBadge(line.lineID, color: Color(hex: line.colorHex))
                    .saturation(row.isPast ? 0 : 1)
                    .opacity(row.isPast ? 0.5 : 1)
            }
        }
    }

    private var kind: some View {
        Text(row.transferStation == nil ? Self.direct : Self.withTransfer)
            .font(.footnote)
            .foregroundStyle(row.isPast ? .textTertiary : .textSecondary)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
    }

    @ViewBuilder
    private var transfer: some View {
        if let station = row.transferStation, let minutes = row.transferMinutes {
            Label {
                Text(
                    LocalizedStringResource(
                        "Cambio en \(station) · \(minutes) min",
                        comment: "Trayectos: estación donde hay que cambiar de tren y los minutos de espera, por ejemplo «Cambio en Victoria Kent · 6 min»."
                    )
                )
            } icon: {
                Image(systemName: "arrow.triangle.swap")
            }
            .labelIconToTitleSpacing(Spacing.xs)
            .font(.footnote)
            .foregroundStyle(row.isPast ? .textTertiary : .textSecondary)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
        }
    }

    private var train: some View {
        Text(
            LocalizedStringResource(
                "Tren \(row.train) hacia \(row.headsign)",
                comment: "Trayectos: número de tren que hay que coger y el final de su recorrido, por ejemplo «Tren 23104 hacia Fuengirola»."
            )
        )
        .font(.caption)
        .foregroundStyle(.textTertiary)
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
    }

    @ViewBuilder
    private var countdown: some View {
        if let minutes = row.minutesAway {
            Text(countdownText(minutes))
                .font(.captionEmphasized)
                .monospacedDigit()
                .foregroundStyle(row.status == .next ? .brandOnPrimary : .brandPrimary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(
                    row.status == .next ? AnyShapeStyle(.brandPrimary) : AnyShapeStyle(.brandPrimarySubtle),
                    in: .capsule
                )
                .fixedSize()
        }
    }

    private func countdownText(_ minutes: Int) -> LocalizedStringResource {
        minutes == 0
            ? LocalizedStringResource(
                "Ahora",
                comment: "Horarios: el tren sale en menos de un minuto."
            )
            : LocalizedStringResource(
                "\(minutes) min",
                comment: "Horarios: minutos que faltan para la salida, por ejemplo «5 min»."
            )
    }

    static func durationText(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60).formatted(
            .units(allowed: [.hours, .minutes], width: .abbreviated)
        )
    }

    private var accessibilityText: Text {
        let duration = Self.durationText(row.durationMinutes)
        let lines = row.lines.map(\.lineID).joined(separator: ", ")
        return switch (row.isPast, row.transferStation) {
        case (true, _):
            Text(
                "Sale a las \(row.departure) y llega a las \(row.arrival), \(duration), línea \(lines). Ya ha salido",
                comment: "Trayectos: lectura de VoiceOver de un tren que ya ha salido; hora de salida, de llegada, duración y líneas."
            )
        case (false, .some(let station)):
            Text(
                "Sale a las \(row.departure) y llega a las \(row.arrival), \(duration), líneas \(lines) con transbordo en \(station)",
                comment: "Trayectos: lectura de VoiceOver de un viaje con transbordo; hora de salida, de llegada, duración, líneas y estación de cambio."
            )
        case (false, .none):
            Text(
                "Sale a las \(row.departure) y llega a las \(row.arrival), \(duration), línea \(lines), directo",
                comment: "Trayectos: lectura de VoiceOver de un tren directo; hora de salida, de llegada, duración y línea."
            )
        }
    }

    private static let direct = LocalizedStringResource(
        "Directo",
        comment: "Trayectos: el tren va de origen a destino sin transbordos."
    )

    private static let withTransfer = LocalizedStringResource(
        "Con transbordo",
        comment: "Trayectos: el viaje necesita cambiar de tren una vez."
    )
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        JourneyRow(
            JourneyTimetableRow(
                id: "1", departure: "07:12", arrival: "07:44", durationMinutes: 32,
                lines: [JourneyLineMark(id: "a", lineID: "C1", colorHex: "DA291C")],
                train: "23104", headsign: "Fuengirola", transferStation: nil, transferMinutes: nil,
                status: .departed, minutesAway: nil
            )
        )
        JourneyRow(
            JourneyTimetableRow(
                id: "2", departure: "07:32", arrival: "08:04", durationMinutes: 32,
                lines: [JourneyLineMark(id: "b", lineID: "C1", colorHex: "DA291C")],
                train: "23106", headsign: "Fuengirola", transferStation: nil, transferMinutes: nil,
                status: .next, minutesAway: 4
            )
        )
        JourneyRow(
            JourneyTimetableRow(
                id: "3", departure: "07:52", arrival: "09:10", durationMinutes: 78,
                lines: [
                    JourneyLineMark(id: "c", lineID: "C1", colorHex: "DA291C"),
                    JourneyLineMark(id: "d", lineID: "C2", colorHex: "0057A8"),
                ],
                train: "23108", headsign: "Málaga-Centro Alameda", transferStation: "Victoria Kent",
                transferMinutes: 6, status: .upcoming, minutesAway: 24
            ),
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Dynamic Type") {
    JourneyRow(
        JourneyTimetableRow(
            id: "3", departure: "07:52", arrival: "09:10", durationMinutes: 78,
            lines: [
                JourneyLineMark(id: "c", lineID: "C1", colorHex: "DA291C"),
                JourneyLineMark(id: "d", lineID: "C2", colorHex: "0057A8"),
            ],
            train: "23108", headsign: "Málaga-Centro Alameda", transferStation: "Victoria Kent",
            transferMinutes: 6, status: .next, minutesAway: 4
        )
    )
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
