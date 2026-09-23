import SwiftUI

struct StationHeader: View {
    private let name: String
    private let subtitle: LocalizedStringResource?

    init(_ name: String, subtitle: LocalizedStringResource?) {
        self.name = name
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(verbatim: name)
                .font(.title2Emphasized)
                .foregroundStyle(.textPrimary)
                .lineLimit(2)
            if let subtitle {
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct StationHeaderSamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxl) {
            StationHeader("Estación La Colina", subtitle: "A 15 minutos a pie")
            StationHeader("Estación La Colina", subtitle: "A 1,2 km")
            StationHeader("Estación La Colina", subtitle: nil)
            StationHeader(
                "Málaga María Zambrano",
                subtitle: "A 15 minutos a pie"
            )
            .frame(width: 222, alignment: .leading)
        }
        .frame(width: 336, alignment: .leading)
        .padding(ScreenLayout.margin)
        .background(.bgPrimary)
    }
}

#Preview("Variantes Figma") {
    StationHeaderSamples()
}

#Preview("Modo oscuro") {
    StationHeaderSamples()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        StationHeaderSamples()
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
