import SwiftUI

struct FavoriteStationCard: View {
    private static let cornerRadius: CGFloat = 12

    static let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    private let name: String
    private let subtitle: String?
    private let lines: [LineMark]
    private let distance: String?
    private let isFavorite: Binding<Bool>?

    init(
        name: String,
        subtitle: String?,
        lines: [LineMark],
        distance: String? = nil,
        isFavorite: Binding<Bool>? = nil
    ) {
        self.name = name
        self.subtitle = subtitle
        self.lines = lines
        self.distance = distance
        self.isFavorite = isFavorite
    }

    var body: some View {
        StationRow(
            name: name,
            subtitle: subtitle,
            lines: lines,
            distance: distance,
            isFavorite: isFavorite,
            favoriteEdge: .leading,
            showsSeparator: false
        )
        .padding(Spacing.sm)
        .background(.bgPrimary, in: Self.shape)
    }
}

private struct FavoriteStationCardSamples: View {
    @State private var isFavorite = true

    private let c1 = Color(hex: "DA291C")
    private let c2 = Color(hex: "0057A8")

    var body: some View {
        VStack(spacing: Spacing.md) {
            FavoriteStationCard(
                name: "Málaga Centro-Alameda",
                subtitle: "Centro · Zona A",
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
                distance: "350 m"
            )
            FavoriteStationCard(
                name: "Málaga María Zambrano",
                subtitle: "Centro · Zona A",
                lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
                distance: "1,2 km",
                isFavorite: $isFavorite
            )
            FavoriteStationCard(
                name: "La Colina",
                subtitle: "Carranque · Zona B",
                lines: [.init("C-1", color: c1)],
                distance: "2,4 km",
                isFavorite: $isFavorite
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
