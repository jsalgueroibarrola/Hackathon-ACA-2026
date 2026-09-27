import SwiftUI

struct DepartureRow: View {
    private let line: String
    private let color: Color
    private let destination: String
    private let time: String
    private let status: StatusChip.Status
    private let statusLabel: LocalizedStringResource?
    private let showsSeparator: Bool

    init(
        _ line: String,
        color: Color,
        to destination: String,
        time: String,
        status: StatusChip.Status = .onTime,
        statusLabel: LocalizedStringResource? = nil,
        showsSeparator: Bool = true
    ) {
        self.line = line
        self.color = color
        self.destination = destination
        self.time = time
        self.status = status
        self.statusLabel = statusLabel
        self.showsSeparator = showsSeparator
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.cardSurfaceStyle) private var cardSurfaceStyle

    var body: some View {
        content
            .foregroundStyle(isCancelled ? .textTertiary : .textPrimary)
            .padding(.horizontal, ScreenLayout.margin)
            .padding(.vertical, Spacing.sm)
            .frame(minHeight: Size.rowMin)
            .overlay(alignment: .bottom) {
                if showsSeparator {
                    Rectangle()
                        .fill(cardSurfaceStyle.separator)
                        .frame(height: Border.hairline)
                        .padding(.leading, ScreenLayout.margin)
                }
            }
            .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.md) {
                    badge
                    destinationText
                }
                HStack(spacing: Spacing.md) {
                    chip
                    Spacer(minLength: Spacing.md)
                    timeText
                }
            }
        } else {
            HStack(spacing: Spacing.md) {
                badge
                destinationText
                chip
                timeText
            }
        }
    }

    private var badge: some View {
        LineBadge(line, color: color)
    }

    private var destinationText: some View {
        Text(verbatim: destination)
            .font(.body)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var chip: some View {
        if let statusLabel {
            StatusChip(status, label: statusLabel)
        }
    }

    private var timeText: some View {
        Text(verbatim: time)
            .font(.timeDeparture)
            .strikethrough(isCancelled)
            .lineLimit(1)
            .fixedSize()
    }

    private var isCancelled: Bool {
        status == .cancelled
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:06",
            status: .onTime,
            statusLabel: "Puntual"
        )
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:06",
            status: .delayed,
            statusLabel: "+5 min"
        )
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:06",
            status: .cancelled,
            statusLabel: "Cancelado"
        )
        DepartureRow(
            "C-2",
            color: c2,
            to: "Fuengirola",
            time: "14:06",
            status: .onTime,
            statusLabel: "Puntual"
        )
        DepartureRow(
            "C-2",
            color: c2,
            to: "Fuengirola",
            time: "14:06",
            status: .delayed,
            statusLabel: "+5 min"
        )
        DepartureRow(
            "C-2",
            color: c2,
            to: "Fuengirola",
            time: "14:06",
            status: .cancelled,
            statusLabel: "Cancelado",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Sin chip y destinos largos") {
    let c1 = Color(hex: "DA291C")

    VStack(spacing: 0) {
        DepartureRow("C-1", color: c1, to: "Fuengirola", time: "14:06")
        DepartureRow(
            "C-1",
            color: c1,
            to: "Málaga María Zambrano",
            time: "14:21"
        )
        DepartureRow(
            "C-4",
            color: .brandPrimary,
            to: "Aeropuerto de Málaga Costa del Sol",
            time: "14:36",
            status: .delayed,
            statusLabel: "+12 min"
        )
        DepartureRow(
            "C-2",
            color: Color(hex: "0057A8"),
            to: "Álora",
            time: "15:02",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    let c1 = Color(hex: "DA291C")

    VStack(spacing: 0) {
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:06",
            status: .onTime,
            statusLabel: "Puntual"
        )
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:21",
            status: .delayed,
            statusLabel: "+5 min"
        )
        DepartureRow(
            "C-1",
            color: c1,
            to: "Fuengirola",
            time: "14:36",
            status: .cancelled,
            statusLabel: "Cancelado",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    VStack(spacing: 0) {
        DepartureRow(
            "C-1",
            color: Color(hex: "DA291C"),
            to: "Fuengirola",
            time: "14:06",
            status: .delayed,
            statusLabel: "+5 min"
        )
        DepartureRow(
            "C-2",
            color: Color(hex: "0057A8"),
            to: "Álora",
            time: "14:21",
            status: .cancelled,
            statusLabel: "Cancelado",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
