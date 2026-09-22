import SwiftUI

struct RailButtonStyle: ButtonStyle {
    enum Variant: CaseIterable {
        case prominent
        case bordered
        case borderless
    }

    let variant: Variant

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(metrics.font)
            .labelIconToTitleSpacing(Spacing.xs)
            .foregroundStyle(foreground(isPressed: configuration.isPressed))
            .lineLimit(1)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(minHeight: metrics.height * scale)
            .background(background(isPressed: configuration.isPressed), in: .capsule)
            .contentShape(.rect.inset(by: -metrics.touchInset))
    }

    private var metrics: Metrics {
        Metrics(controlSize)
    }

    private func foreground(isPressed: Bool) -> Color {
        switch (isEnabled, variant, isPressed) {
        case (false, _, _): .textDisabled
        case (true, .prominent, _): .brandOnPrimary
        case (true, _, true): .brandPrimaryPressed
        case (true, _, false): .brandPrimary
        }
    }

    private func background(isPressed: Bool) -> Color {
        switch (isEnabled, variant, isPressed) {
        case (false, .borderless, _): .clear
        case (false, _, _): .fillTertiary
        case (true, .prominent, false): .brandPrimary
        case (true, .prominent, true): .brandPrimaryPressed
        case (true, .bordered, false): .brandTintFill
        case (true, .bordered, true): .brandPrimarySubtle
        case (true, .borderless, false): .clear
        case (true, .borderless, true): .interactivePressedOverlay
        }
    }
}

extension RailButtonStyle {
    fileprivate enum Metrics {
        case small
        case medium
        case large

        init(_ controlSize: ControlSize) {
            self =
                switch controlSize {
                case .mini, .small: .small
                case .large, .extraLarge: .large
                default: .medium
                }
        }

        var height: CGFloat {
            switch self {
            case .small: Size.buttonSm
            case .medium: Size.buttonMd
            case .large: Size.buttonLg
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: 10
            case .medium: 14
            case .large: Spacing.xl
            }
        }

        var font: Font {
            switch self {
            case .small, .medium: .subheadline
            case .large: .body
            }
        }

        var touchInset: CGFloat {
            max(0, (Size.touchMin - height) / 2)
        }
    }
}

extension ButtonStyle where Self == RailButtonStyle {
    static func rail(_ variant: RailButtonStyle.Variant) -> Self {
        RailButtonStyle(variant: variant)
    }
}

#Preview("Variantes Figma") {
    Grid(horizontalSpacing: Spacing.xxl, verticalSpacing: Spacing.lg) {
        ForEach(RailButtonStyle.Variant.allCases, id: \.self) { variant in
            ForEach([ControlSize.large, .regular, .small], id: \.self) { size in
                GridRow {
                    Button("Ver horarios") {}
                    Button("Ver horarios") {}
                        .disabled(true)
                }
                .buttonStyle(.rail(variant))
                .controlSize(size)
            }
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Con icono") {
    VStack(spacing: Spacing.lg) {
        Button("Ver horarios", systemImage: "clock") {}
            .buttonStyle(.rail(.prominent))
            .controlSize(.large)
        Button("Añadir a favoritos", systemImage: "star") {}
            .buttonStyle(.rail(.bordered))
        Button("Compartir", systemImage: "square.and.arrow.up") {}
            .buttonStyle(.rail(.borderless))
            .controlSize(.small)
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    VStack(spacing: Spacing.lg) {
        ForEach(RailButtonStyle.Variant.allCases, id: \.self) { variant in
            Button("Ver horarios") {}
                .buttonStyle(.rail(variant))
                .controlSize(.large)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}
