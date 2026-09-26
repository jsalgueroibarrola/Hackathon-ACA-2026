import SwiftUI

struct TimetableRow: View {
    private let row: StationTimetableRow
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ row: StationTimetableRow, showsSeparator: Bool = true) {
        self.row = row
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        content
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.sm)
            .frame(minHeight: Size.rowMin)
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

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.md) {
                    time
                    countdown
                }
                badge
                destination
                train
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: Spacing.md) {
                time
                badge
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    destination
                    train
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                countdown
            }
        }
    }

    private var time: some View {
        Text(verbatim: row.time)
            .font(.timeDeparture)
            .foregroundStyle(row.isPast ? .textTertiary : .textPrimary)
    }

    private var badge: some View {
        LineBadge(row.lineID, color: Color(hex: row.colorHex))
            .saturation(row.isPast ? 0 : 1)
            .opacity(row.isPast ? 0.5 : 1)
    }

    private var destination: some View {
        Text(verbatim: row.destination)
            .font(row.status == .next ? .bodyEmphasized : .body)
            .foregroundStyle(row.isPast ? .textTertiary : .textPrimary)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
    }

    private var train: some View {
        Text(
            LocalizedStringResource(
                "Tren \(row.train)",
                comment: "Horarios: número de tren de Renfe, por ejemplo «Tren 23104»."
            )
        )
        .font(.caption)
        .monospacedDigit()
        .foregroundStyle(.textTertiary)
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

    private var accessibilityText: Text {
        switch (row.isPast, row.minutesAway) {
        case (true, _):
            Text(
                "\(row.time), línea \(row.lineID) hacia \(row.destination). Ya ha salido",
                comment: "Horarios: lectura de VoiceOver de una salida que ya ha pasado; hora, línea y destino."
            )
        case (false, .some(let minutes)):
            Text(
                "\(row.time), línea \(row.lineID) hacia \(row.destination). Sale en \(minutes) min",
                comment: "Horarios: lectura de VoiceOver de una salida próxima; hora, línea, destino y minutos que faltan."
            )
        case (false, .none):
            Text(
                "\(row.time), línea \(row.lineID) hacia \(row.destination)",
                comment: "Horarios: lectura de VoiceOver de una salida; hora, línea y destino."
            )
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        TimetableRow(
            StationTimetableRow(
                id: "1", lineID: "C-1", colorHex: "DA291C", destination: "Fuengirola",
                train: "23104", time: "07:12", status: .departed, minutesAway: nil
            )
        )
        TimetableRow(
            StationTimetableRow(
                id: "2", lineID: "C-2", colorHex: "0057A8", destination: "Málaga-Centro Alameda",
                train: "36008", time: "07:20", status: .next, minutesAway: 4
            )
        )
        TimetableRow(
            StationTimetableRow(
                id: "3", lineID: "C-1", colorHex: "DA291C", destination: "Fuengirola",
                train: "23106", time: "07:32", status: .upcoming, minutesAway: 16
            )
        )
        TimetableRow(
            StationTimetableRow(
                id: "4", lineID: "C-2", colorHex: "0057A8", destination: "Álora",
                train: "36010", time: "08:40", status: .upcoming, minutesAway: nil
            ),
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}
#endif
