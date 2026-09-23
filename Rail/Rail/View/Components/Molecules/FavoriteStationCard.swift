import SwiftUI

struct FavoriteStationCard: View {
    private static let cornerRadius: CGFloat = 12

    static let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    private let name: String
    private let subtitle: String?
    private let lines: [LineMark]

    init(name: String, subtitle: String?, lines: [LineMark]) {
        self.name = name
        self.subtitle = subtitle
        self.lines = lines
    }

    var body: some View {
        StationRow(
            name: name,
            subtitle: subtitle,
            lines: lines,
            showsSeparator: false
        )
        .padding(Spacing.sm)
        .background(.bgPrimary, in: Self.shape)
    }
}

private struct FavoriteStationCardSamples: View {
    private let c1 = Color(hex: "DA291C")
    private let c2 = Color(hex: "0057A8")

    var body: some View {
        VStack(spacing: Spacing.md) {
            FavoriteStationCard(
                name: "Málaga C. Alameda",
                subtitle: "Centro · Zona A",
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
            )
            FavoriteStationCard(
                name: "Málaga M. Zambrano",
                subtitle: "Centro · Zona A",
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
            )
            FavoriteStationCard(
                name: "La Colina",
                subtitle: "Centro · Zona B",
                lines: [.init("C-1", color: c1)]
            )
            FavoriteStationCard(
                name: "Victoria Kent",
                subtitle: nil,
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
            )
        }
        .frame(width: 360)
        .padding(ScreenLayout.margin)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    FavoriteStationCardSamples()
}

#Preview("Modo oscuro") {
    FavoriteStationCardSamples()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        FavoriteStationCardSamples()
    }
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
