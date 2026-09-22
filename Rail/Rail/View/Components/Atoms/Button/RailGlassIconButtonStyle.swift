import SwiftUI

struct RailGlassIconButtonStyle: ButtonStyle {
    let variant: RailGlassButtonStyle.Variant

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundStyle(variant.foreground(isEnabled: isEnabled))
            .frame(width: diameter * scale, height: diameter * scale)
            .glassEffect(variant.glass(isEnabled: isEnabled), in: .circle)
            .contentShape(.circle)
    }

    private var diameter: CGFloat {
        switch controlSize {
        case .large, .extraLarge: Size.glassControlLg
        default: Size.glassControl
        }
    }
}

extension ButtonStyle where Self == RailGlassIconButtonStyle {
    static func railGlassIcon(_ variant: RailGlassButtonStyle.Variant) -> Self {
        RailGlassIconButtonStyle(variant: variant)
    }
}

#Preview("Variantes Figma") {
    Grid(horizontalSpacing: Spacing.xxl, verticalSpacing: Spacing.lg) {
        ForEach([ControlSize.regular, .large], id: \.self) { size in
            ForEach(RailGlassButtonStyle.Variant.allCases, id: \.self) { variant in
                GridRow {
                    Button("Mi ubicación", systemImage: "location.fill") {}
                    Button("Mi ubicación", systemImage: "location.fill") {}
                        .disabled(true)
                }
                .buttonStyle(.railGlassIcon(variant))
                .controlSize(size)
            }
        }
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.lg) {
        Button("Mi ubicación", systemImage: "location.fill") {}
            .buttonStyle(.railGlassIcon(.clear))
        Button("Mi ubicación", systemImage: "location.fill") {}
            .buttonStyle(.railGlassIcon(.tinted))
            .controlSize(.large)
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}
