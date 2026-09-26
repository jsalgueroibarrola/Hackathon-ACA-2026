import SwiftUI

struct RailGlassButtonStyle: ButtonStyle {
    enum Variant: CaseIterable {
        case clear
        case tinted
    }

    let variant: Variant

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(metrics.font)
            .labelIconToTitleSpacing(Spacing.xs)
            .foregroundStyle(variant.foreground(isEnabled: isEnabled))
            .lineLimit(1)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(minHeight: metrics.height * scale)
            .glassEffect(variant.glass(isEnabled: isEnabled), in: .capsule)
            .contentShape(.rect.inset(by: -metrics.touchInset))
    }

    private var metrics: Metrics {
        Metrics(controlSize)
    }
}

extension RailGlassButtonStyle.Variant {
    func glass(isEnabled: Bool) -> Glass {
        switch (isEnabled, self) {
        case (false, _): .regular
        case (true, .clear): .regular.interactive()
        case (true, .tinted): .regular.tint(.glassFillTinted).interactive()
        }
    }

    func foreground(isEnabled: Bool) -> Color {
        switch (isEnabled, self) {
        case (false, _): .textDisabled
        case (true, .clear): .glassText
        case (true, .tinted): .brandOnPrimary
        }
    }
}

extension RailGlassButtonStyle {
    fileprivate enum Metrics {
        case small
        case regular

        init(_ controlSize: ControlSize) {
            self =
                switch controlSize {
                case .mini, .small: .small
                default: .regular
                }
        }

        var height: CGFloat {
            switch self {
            case .small: Size.buttonMd
            case .regular: Size.glassControl
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: Spacing.md
            case .regular: Spacing.xl
            }
        }

        var font: Font {
            switch self {
            case .small: .subheadlineEmphasized
            case .regular: .bodyMedium
            }
        }

        var touchInset: CGFloat {
            max(0, (Size.touchMin - height) / 2)
        }
    }
}

extension ButtonStyle where Self == RailGlassButtonStyle {
    static func railGlass(_ variant: RailGlassButtonStyle.Variant) -> Self {
        RailGlassButtonStyle(variant: variant)
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    Grid(horizontalSpacing: Spacing.xxl, verticalSpacing: Spacing.lg) {
        ForEach(RailGlassButtonStyle.Variant.allCases, id: \.self) { variant in
            ForEach([ControlSize.regular, .small], id: \.self) { size in
                GridRow {
                    Button("Ver en el mapa") {}
                    Button("Ver en el mapa") {}
                        .disabled(true)
                }
                .buttonStyle(.railGlass(variant))
                .controlSize(size)
            }
        }
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    VStack(spacing: Spacing.lg) {
        Button("Ver en el mapa") {}
            .buttonStyle(.railGlass(.clear))
        Button("Ver en el mapa") {}
            .buttonStyle(.railGlass(.tinted))
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}
#endif
