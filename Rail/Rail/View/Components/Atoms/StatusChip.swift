import SwiftUI

struct StatusChip: View {
    enum Status: CaseIterable {
        case onTime
        case delayed
        case cancelled
    }

    private let label: LocalizedStringResource
    private let status: Status
    private let showsDot: Bool
    @ScaledMetric(relativeTo: .caption) private var height: CGFloat = Size.chip
    @ScaledMetric(relativeTo: .caption) private var dotSize: CGFloat = 6

    init(
        _ status: Status,
        label: LocalizedStringResource,
        showsDot: Bool = true
    ) {
        self.status = status
        self.label = label
        self.showsDot = showsDot
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if showsDot {
                Circle()
                    .fill(status.dotColor)
                    .frame(width: dotSize, height: dotSize)
                    .accessibilityHidden(true)
            }
            Text(label)
                .font(.captionEmphasized)
                .tracking(Tracking.wide)
                .foregroundStyle(status.textColor)
                .lineLimit(1)
        }
        .padding(.horizontal, Spacing.sm)
        .frame(minHeight: height)
        .background(status.backgroundColor, in: .capsule)
        .fixedSize()
    }
}

extension StatusChip.Status {
    fileprivate var dotColor: Color {
        switch self {
        case .onTime: .transitOnTime
        case .delayed: .transitDelayed
        case .cancelled: .transitCancelled
        }
    }

    fileprivate var textColor: Color {
        switch self {
        case .onTime: .transitOnTimeText
        case .delayed: .transitDelayedText
        case .cancelled: .transitCancelledText
        }
    }

    fileprivate var backgroundColor: Color {
        switch self {
        case .onTime: .transitOnTimeBg
        case .delayed: .transitDelayedBg
        case .cancelled: .transitCancelledBg
        }
    }
}

#Preview("Variantes Figma") {
    VStack(spacing: Spacing.xxl) {
        HStack(spacing: Spacing.xxxxl) {
            StatusChip(.onTime, label: "Puntual")
            StatusChip(.delayed, label: "+\(5) min")
            StatusChip(.cancelled, label: "Cancelado")
        }
        HStack(spacing: Spacing.xxxxl) {
            StatusChip(.onTime, label: "Puntual", showsDot: false)
            StatusChip(.delayed, label: "+\(12) min", showsDot: false)
            StatusChip(.cancelled, label: "Cancelado", showsDot: false)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.sm) {
        StatusChip(.onTime, label: "Puntual")
        StatusChip(.delayed, label: "+\(5) min")
        StatusChip(.cancelled, label: "Cancelado")
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    VStack(spacing: Spacing.md) {
        StatusChip(.onTime, label: "Puntual")
        StatusChip(.delayed, label: "+\(5) min")
        StatusChip(.cancelled, label: "Cancelado")
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
