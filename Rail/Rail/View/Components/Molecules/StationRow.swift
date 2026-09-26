import SwiftUI

struct StationRow: View {
    enum Accessory {
        case chevron
        case checkmark
        case hidden
    }

    private let name: String
    private let subtitle: String?
    private let lines: [LineMark]
    private let distance: String?
    private let isFavorite: Binding<Bool>?
    private let favoriteEdge: HorizontalEdge
    private let accessory: Accessory
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let minHeight: CGFloat = 60
    private static let metaSpacing: CGFloat = 6

    static let listRowInsets = EdgeInsets(
        top: 0,
        leading: ScreenLayout.margin,
        bottom: 0,
        trailing: ScreenLayout.margin
    )

    init(
        name: String,
        subtitle: String?,
        lines: [LineMark],
        distance: String? = nil,
        isFavorite: Binding<Bool>? = nil,
        favoriteEdge: HorizontalEdge = .trailing,
        accessory: Accessory = .chevron,
        showsSeparator: Bool = true
    ) {
        self.name = name
        self.subtitle = subtitle
        self.lines = lines
        self.distance = distance
        self.isFavorite = isFavorite
        self.favoriteEdge = favoriteEdge
        self.accessory = accessory
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            if favoriteEdge == .leading {
                favoriteToggle
            }
            content
                .accessibilityElement(children: .combine)
            if favoriteEdge == .trailing {
                favoriteToggle
            }
            accessoryView
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.sm)
        .frame(minHeight: Self.minHeight)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(.interactiveSeparator)
                    .frame(height: Border.hairline)
                    .padding(.leading, ScreenLayout.margin)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(verbatim: name)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
            meta
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var meta: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                badges
                subtitleText
                distanceText
            }
        } else {
            HStack(spacing: Self.metaSpacing) {
                badges
                subtitleText
                    .lineLimit(1)
                Spacer(minLength: 0)
                distanceText
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }

    private var badges: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(lines) { line in
                LineBadge(line.id, color: line.color)
            }
        }
    }

    @ViewBuilder
    private var subtitleText: some View {
        if let subtitle {
            Text(verbatim: subtitle)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
        }
    }

    @ViewBuilder
    private var distanceText: some View {
        if let distance {
            Text(verbatim: distance)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
        }
    }

    @ViewBuilder
    private var favoriteToggle: some View {
        if let isFavorite {
            Toggle(isOn: isFavorite) {}
                .toggleStyle(.favorite)
                .controlSize(.small)
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.interactiveIconSubtle)
                .accessibilityHidden(true)
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.brandPrimary)
                .accessibilityHidden(true)
        case .hidden:
            EmptyView()
        }
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1)],
            distance: "~250 m"
        )
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-2", color: c2)],
            distance: "~250 m"
        )
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            distance: "~250 m",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Con favorito") {
    @Previewable @State var uno = true
    @Previewable @State var dos = false
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            distance: "~250 m",
            isFavorite: $uno
        )
        StationRow(
            name: "Los Boliches",
            subtitle: "Fuengirola · Zona C",
            lines: [.init("C-1", color: c1)],
            isFavorite: $dos
        )
        StationRow(
            name: "La Colina",
            subtitle: "Carranque · Zona B",
            lines: [.init("C-1", color: c1)],
            distance: "2,4 km",
            isFavorite: $uno,
            favoriteEdge: .leading,
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Selector") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Málaga María Zambrano",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            accessory: .checkmark
        )
        StationRow(
            name: "Guadalhorce",
            subtitle: "Centro · Zona B",
            lines: [.init("C-1", color: c1)],
            accessory: .hidden,
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Sin distancia y nombres largos") {
    let c1 = Color(hex: "DA291C")

    VStack(spacing: 0) {
        StationRow(
            name: "Universidad de Málaga – Andalucía Tech",
            subtitle: "Teatinos · Zona A",
            lines: [.init("C-1", color: c1)]
        )
        StationRow(
            name: "Aeropuerto de Málaga Costa del Sol",
            subtitle: "Churriana · Autobús interurbano · Autobús urbano",
            lines: [.init("C-1", color: c1)],
            distance: "~1,2 km",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Sin subtítulo") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Victoria Kent",
            subtitle: nil,
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)]
        )
        StationRow(
            name: "Benalmádena-Arroyo de la Miel",
            subtitle: nil,
            lines: [.init("C-1", color: c1)],
            distance: "~18 km",
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            distance: "~250 m"
        )
        StationRow(
            name: "Los Boliches",
            subtitle: "Fuengirola · Zona C",
            lines: [.init("C-1", color: c1)],
            distance: "~18 km",
            accessory: .checkmark,
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    @Previewable @State var favorita = true
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(
            name: "Málaga Centro-Alameda",
            subtitle: "Centro · Zona A",
            lines: [.init("C-1", color: c1), .init("C-2", color: c2)],
            distance: "~250 m",
            isFavorite: $favorita,
            favoriteEdge: .leading,
            showsSeparator: false
        )
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
