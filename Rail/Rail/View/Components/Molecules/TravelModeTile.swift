import SwiftUI

struct TravelModeTile: View {
    private let mode: TravelMode
    private let time: String?
    private let detail: String?

    @ScaledMetric(relativeTo: .headline) private var iconSize: CGFloat = Size.iconMd

    init(_ mode: TravelMode, time: String?, detail: String?) {
        self.mode = mode
        self.time = time
        self.detail = detail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: mode.symbolName)
                .font(.headline)
                .foregroundStyle(.brandPrimary)
                .frame(width: iconSize, height: iconSize, alignment: .leading)
                .accessibilityHidden(true)
            Text(mode.title)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
            if let time {
                Text(verbatim: time)
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(.textPrimary)
            } else {
                Text(Self.unavailable)
                    .font(.headline)
                    .foregroundStyle(.textTertiary)
            }
            if let detail {
                Text(verbatim: detail)
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(Spacing.md)
        .background(.bgSecondary, in: .rect(cornerRadius: Radius.md, style: .continuous))
        .contentShape(.rect(cornerRadius: Radius.md, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private static let unavailable = LocalizedStringResource(
        "No disponible",
        comment: "Detalle de estación: tiempo de un medio de transporte que Mapas no ha podido calcular."
    )
}

#Preview {
    Grid(horizontalSpacing: Spacing.sm, verticalSpacing: Spacing.sm) {
        GridRow {
            TravelModeTile(.walking, time: "24 min", detail: "1,7 km")
            TravelModeTile(.cycling, time: "8 min", detail: "1,9 km")
        }
        GridRow {
            TravelModeTile(.automobile, time: "6 min", detail: "2,3 km")
            TravelModeTile(.transit, time: nil, detail: nil)
        }
    }
    .cardSurface()
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
}
