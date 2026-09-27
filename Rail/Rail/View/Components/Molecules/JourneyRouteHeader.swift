import SwiftUI

struct JourneyRouteHeader: View {
    private let originName: String
    private let destinationName: String
    private let summary: JourneySummary?
    private let onSwap: () -> Void

    @State private var swapTurns = 0
    @ScaledMetric(relativeTo: .headline) private var dot: CGFloat = 12
    @ScaledMetric(relativeTo: .headline) private var connector: CGFloat = Spacing.lg

    init(
        originName: String,
        destinationName: String,
        summary: JourneySummary?,
        onSwap: @escaping () -> Void
    ) {
        self.originName = originName
        self.destinationName = destinationName
        self.summary = summary
        self.onSwap = onSwap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                stations
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(JourneySearchCard.swapTitle, systemImage: "arrow.up.arrow.down") {
                    withAnimation(.snappy) {
                        swapTurns += 1
                    }
                    onSwap()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.rail(.bordered))
                .rotationEffect(.degrees(Double(swapTurns) * 180))
            }
            if let summary, summary.count > 0 {
                summaryView(summary)
            }
        }
        .padding(Spacing.md)
        .background(.bgSecondary, in: .rect(cornerRadius: Radius.md, style: .continuous))
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.md)
    }

    private var stations: some View {
        Grid(alignment: .leading, horizontalSpacing: Spacing.md, verticalSpacing: Spacing.xxs) {
            GridRow {
                Circle()
                    .strokeBorder(.brandPrimary, lineWidth: Border.thick)
                    .frame(width: dot, height: dot)
                    .accessibilityHidden(true)
                name(originName, title: JourneySearchCard.originTitle)
            }
            GridRow {
                Rectangle()
                    .fill(.borderDefault)
                    .frame(width: Border.thick, height: connector)
                    .gridColumnAlignment(.center)
                    .accessibilityHidden(true)
                Color.clear
                    .frame(height: 0)
            }
            GridRow {
                Circle()
                    .fill(.brandPrimary)
                    .frame(width: dot, height: dot)
                    .accessibilityHidden(true)
                name(destinationName, title: JourneySearchCard.destinationTitle)
            }
        }
    }

    private func name(_ name: String, title: LocalizedStringResource) -> some View {
        Text(verbatim: name)
            .font(.headline)
            .foregroundStyle(.textPrimary)
            .accessibilityLabel(Text(title))
            .accessibilityValue(Text(verbatim: name))
    }

    private func summaryView(_ summary: JourneySummary) -> some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                ForEach(summary.lines) { line in
                    LineBadge(line.lineID, color: Color(hex: line.colorHex))
                }
            }
            Text(
                LocalizedStringResource(
                    "\(summary.count) trenes",
                    comment: "Trayectos: cuántos trenes hay entre las dos estaciones el día elegido."
                )
            )
            .font(.footnote)
            .foregroundStyle(.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack {
        JourneyRouteHeader(
            originName: "Málaga-Centro Alameda",
            destinationName: "Fuengirola",
            summary: JourneySummary(
                count: 42,
                lines: [JourneyLineMark(id: "C1", lineID: "C1", colorHex: "DA291C")]
            )
        ) {}
        JourneyRouteHeader(
            originName: "Fuengirola",
            destinationName: "Álora",
            summary: nil
        ) {}
    }
    .background(.bgPrimary)
}
#endif
