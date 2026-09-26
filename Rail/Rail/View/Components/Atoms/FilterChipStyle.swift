import SwiftUI

struct FilterChipStyle: ButtonStyle {
    let isSelected: Bool

    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var scale: CGFloat = 1

    private static let horizontalPadding: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadlineEmphasized)
            .labelIconToTitleSpacing(Spacing.xs)
            .foregroundStyle(variant.foreground(isEnabled: isEnabled))
            .lineLimit(1)
            .padding(.horizontal, Self.horizontalPadding)
            .frame(minHeight: Size.buttonMd * scale)
            .glassEffect(variant.glass(isEnabled: isEnabled), in: .capsule)
            .contentShape(.rect.inset(by: -Self.touchInset))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var variant: RailGlassButtonStyle.Variant {
        isSelected ? .tinted : .clear
    }

    private static let touchInset = max(0, (Size.touchMin - Size.buttonMd) / 2)
}

extension ButtonStyle where Self == FilterChipStyle {
    static func filterChip(isSelected: Bool) -> Self {
        FilterChipStyle(isSelected: isSelected)
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    HStack(spacing: Spacing.md) {
        Button("Todas") {}
            .buttonStyle(.filterChip(isSelected: false))
        Button("Todas") {}
            .buttonStyle(.filterChip(isSelected: true))
        Button("Favoritas", systemImage: "star.fill") {}
            .buttonStyle(.filterChip(isSelected: false))
        Button("Favoritas", systemImage: "star.fill") {}
            .buttonStyle(.filterChip(isSelected: true))
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}

#Preview("Fila con scroll") {
    @Previewable @State var seleccionado = "Todas"
    let filtros = ["Todas", "Favoritas", "Cercanas", "C-1", "C-2", "C-4"]

    ZStack {
        LinearGradient(
            colors: [.brandCercanias, .brandPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView(.horizontal) {
            GlassEffectContainer(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    ForEach(filtros, id: \.self) { filtro in
                        Button(filtro) { seleccionado = filtro }
                            .buttonStyle(.filterChip(isSelected: seleccionado == filtro))
                    }
                }
                .padding(.horizontal, ScreenLayout.margin)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.md) {
        Button("Cercanas") {}
            .buttonStyle(.filterChip(isSelected: false))
        Button("Cercanas") {}
            .buttonStyle(.filterChip(isSelected: true))
        Button("Cercanas") {}
            .buttonStyle(.filterChip(isSelected: false))
            .disabled(true)
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        Button("Favoritas", systemImage: "star.fill") {}
            .buttonStyle(.filterChip(isSelected: true))
        Button("Cercanas") {}
            .buttonStyle(.filterChip(isSelected: false))
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
#endif
