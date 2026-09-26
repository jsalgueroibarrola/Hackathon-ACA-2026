import SwiftUI

struct StationFeatureRow: View {
    private let title: LocalizedStringResource
    private let systemImage: String
    private let isKnown: Bool

    @ScaledMetric(relativeTo: .body) private var iconBox: CGFloat = Size.iconLg

    init(_ title: LocalizedStringResource, systemImage: String, isKnown: Bool = true) {
        self.title = title
        self.systemImage = systemImage
        self.isKnown = isKnown
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: systemImage)
                .font(.subheadlineEmphasized)
                .foregroundStyle(isKnown ? .brandPrimary : .textTertiary)
                .frame(width: iconBox, height: iconBox)
                .background(isKnown ? .brandPrimarySubtle : .fillTertiary, in: .circle)
                .accessibilityHidden(true)
            Text(title)
                .font(.body)
                .foregroundStyle(isKnown ? .textPrimary : .textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: Size.rowMin)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Spacing.xs) {
        StationFeatureRow("Adaptada para movilidad reducida", systemImage: "figure.roll")
        StationFeatureRow("Metro", systemImage: "tram.fill.tunnel")
        StationFeatureRow("Sin datos de accesibilidad", systemImage: "questionmark.circle", isKnown: false)
    }
    .cardSurface()
    .padding(ScreenLayout.margin)
    .background(.bgSecondary)
}
#endif
