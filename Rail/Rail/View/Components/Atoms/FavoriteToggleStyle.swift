import SwiftUI

struct FavoriteToggleStyle: ToggleStyle {
    @Environment(\.controlSize) private var controlSize
    @ScaledMetric private var scale: CGFloat = 1

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "star.fill" : "star")
                .font(.system(size: metrics.iconSize * scale))
                .foregroundStyle(
                    configuration.isOn
                        ? Color.interactiveFavorite : .interactiveIconSubtle
                )
                .contentTransition(.symbolEffect(.replace))
                .frame(
                    width: metrics.side * scale,
                    height: metrics.side * scale
                )
        }
        .buttonStyle(.plain)
        .contentShape(.rect.inset(by: -metrics.touchInset))
        .accessibilityLabel(
            configuration.isOn ? Self.removeLabel : Self.addLabel
        )
        .accessibilityAddTraits(
            configuration.isOn ? [.isToggle, .isSelected] : .isToggle
        )
    }

    private var metrics: Metrics {
        Metrics(controlSize)
    }

    static let addLabel = LocalizedStringResource(
        "Añadir a favoritos",
        comment:
            "Acción del botón de favorito cuando la estación todavía no lo es"
    )

    static let removeLabel = LocalizedStringResource(
        "Quitar de favoritos",
        comment:
            "Acción del botón de favorito cuando la estación ya es favorita"
    )
}

extension FavoriteToggleStyle {
    fileprivate enum Metrics {
        case small
        case regular

        static let smallSide: CGFloat = 28
        static let smallIconSize: CGFloat = 20

        init(_ controlSize: ControlSize) {
            self =
                switch controlSize {
                case .mini, .small: .small
                default: .regular
                }
        }

        var side: CGFloat {
            switch self {
            case .small: Self.smallSide
            case .regular: Size.touchMin
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: Self.smallIconSize
            case .regular: Size.iconMd
            }
        }

        var touchInset: CGFloat {
            max(0, (Size.touchMin - side) / 2)
        }
    }
}

extension ToggleStyle where Self == FavoriteToggleStyle {
    static var favorite: Self {
        FavoriteToggleStyle()
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    Grid(horizontalSpacing: Spacing.xxl, verticalSpacing: Spacing.lg) {
        GridRow {
            Toggle(isOn: .constant(false)) {}
            Toggle(isOn: .constant(true)) {}
        }
        GridRow {
            Toggle(isOn: .constant(false)) {}
            Toggle(isOn: .constant(true)) {}
        }
        .controlSize(.small)
    }
    .toggleStyle(.favorite)
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Interactivo") {
    @Previewable @State var isFavorite = false
    @Previewable @State var isNearby = true

    VStack(spacing: Spacing.xl) {
        Toggle(isOn: $isFavorite) {}
            .toggleStyle(.favorite)
        HStack(spacing: Spacing.sm) {
            Text(verbatim: "Málaga María Zambrano")
                .font(.body)
                .foregroundStyle(.textPrimary)
            Toggle(isOn: $isNearby) {}
                .toggleStyle(.favorite)
                .controlSize(.small)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.xl) {
        Toggle(isOn: .constant(false)) {}
        Toggle(isOn: .constant(true)) {}
        Toggle(isOn: .constant(false)) {}
            .controlSize(.small)
        Toggle(isOn: .constant(true)) {}
            .controlSize(.small)
    }
    .toggleStyle(.favorite)
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    HStack(spacing: Spacing.xl) {
        Toggle(isOn: .constant(true)) {}
        Toggle(isOn: .constant(true)) {}
            .controlSize(.small)
    }
    .toggleStyle(.favorite)
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .dynamicTypeSize(.accessibility2)
}
#endif
