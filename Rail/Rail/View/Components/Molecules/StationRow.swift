import SwiftUI

struct StationRow: View {
    private let name: String
    private let subtitle: String
    private let lines: [LineMark]
    private let distance: String?
    private let isFavorite: Binding<Bool>?
    private let showsSeparator: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let minHeight: CGFloat = 60

    init(
        name: String,
        subtitle: String,
        lines: [LineMark],
        distance: String? = nil,
        isFavorite: Binding<Bool>? = nil,
        showsSeparator: Bool = true
    ) {
        self.name = name
        self.subtitle = subtitle
        self.lines = lines
        self.distance = distance
        self.isFavorite = isFavorite
        self.showsSeparator = showsSeparator
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            content
                .accessibilityElement(children: .combine)
            favoriteToggle
            chevron
        }
        .padding(.horizontal, ScreenLayout.margin)
        .padding(.vertical, Spacing.md)
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

    @ViewBuilder
    private var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                info
                distanceText
                badges
            }
        } else {
            HStack(spacing: Spacing.md) {
                info
                distanceText
                badges
            }
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(verbatim: name)
                .font(.headline)
                .foregroundStyle(.textPrimary)
            Text(verbatim: subtitle)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
        }
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var distanceText: some View {
        if let distance {
            Text(verbatim: distance)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
                .lineLimit(1)
                .fixedSize()
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
    private var favoriteToggle: some View {
        if let isFavorite {
            Toggle(isOn: isFavorite) {}
                .toggleStyle(.favorite)
                .controlSize(.small)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.interactiveIconSubtle)
            .accessibilityHidden(true)
    }
}

#Preview("Variantes Figma") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-1", color: c1)], distance: "~250 m")
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-2", color: c2)], distance: "~250 m")
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-1", color: c1), .init("C-2", color: c2)], distance: "~250 m", showsSeparator: false)
    }
    .background(.bgPrimary)
}

#Preview("Con favorito") {
    @Previewable @State var uno = true
    @Previewable @State var dos = false
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-1", color: c1), .init("C-2", color: c2)], distance: "~250 m", isFavorite: $uno)
        StationRow(name: "Los Boliches", subtitle: "Fuengirola · Zona C", lines: [.init("C-1", color: c1)], isFavorite: $dos, showsSeparator: false)
    }
    .background(.bgPrimary)
}

#Preview("Sin distancia y nombres largos") {
    let c1 = Color(hex: "DA291C")

    VStack(spacing: 0) {
        StationRow(name: "Universidad de Málaga – Andalucía Tech", subtitle: "Teatinos · Zona A", lines: [.init("C-1", color: c1)])
        StationRow(name: "Aeropuerto de Málaga Costa del Sol", subtitle: "Churriana · Zona B", lines: [.init("C-1", color: c1)], distance: "~1,2 km", showsSeparator: false)
    }
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-1", color: c1), .init("C-2", color: c2)], distance: "~250 m")
        StationRow(name: "Los Boliches", subtitle: "Fuengirola · Zona C", lines: [.init("C-1", color: c1)], distance: "~18 km", showsSeparator: false)
    }
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    @Previewable @State var favorita = true
    let c1 = Color(hex: "DA291C")
    let c2 = Color(hex: "0057A8")

    VStack(spacing: 0) {
        StationRow(name: "Málaga Centro-Alameda", subtitle: "Centro · Zona A", lines: [.init("C-1", color: c1), .init("C-2", color: c2)], distance: "~250 m", isFavorite: $favorita, showsSeparator: false)
    }
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
