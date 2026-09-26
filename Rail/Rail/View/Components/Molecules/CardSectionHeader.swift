import SwiftUI

struct CardSectionHeader<Accessory: View>: View {
    private static var bottomPadding: CGFloat { 6 }
    private static var rowSpacing: CGFloat { 6 }

    private let title: LocalizedStringResource
    private let systemImage: String?
    private let detail: LocalizedStringResource?
    private let accessory: Accessory

    init(
        _ title: LocalizedStringResource,
        systemImage: String? = nil,
        detail: LocalizedStringResource? = nil,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.detail = detail
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: Self.rowSpacing) {
            label
            Spacer(minLength: Spacing.sm)
            accessory
        }
        .padding(.top, Spacing.lg)
        .padding(.bottom, Self.bottomPadding)
    }

    private var label: some View {
        HStack(spacing: Self.rowSpacing) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            text
        }
        .font(.footnote)
        .foregroundStyle(.textTertiary)
        .accessibilityElement(children: .combine)
    }

    private var text: Text {
        if let detail {
            Text(
                "\(Text(title)) · \(Text(detail))",
                comment: "Cabecera de sección de una tarjeta: título seguido de un detalle, por ejemplo «Próximos trenes · programados»."
            )
        } else {
            Text(title)
        }
    }
}

#if DEBUG
private struct CardSectionHeaderSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            CardSectionHeader("Próximos trenes", systemImage: "clock")
            CardSectionHeader("Próximos trenes", systemImage: "clock", detail: "programados")
            CardSectionHeader("Estaciones favoritas")
            CardSectionHeader("Próximos trenes", systemImage: "clock") {
                Button("Cambiar") {}
                    .buttonStyle(.rail(.borderless))
                    .controlSize(.small)
            }
        }
        .frame(width: 336)
        .padding(ScreenLayout.margin)
        .background(.bgPrimary)
    }
}

#Preview("Variantes Figma") {
    CardSectionHeaderSamples()
}

#Preview("Modo oscuro") {
    CardSectionHeaderSamples()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    CardSectionHeaderSamples()
        .dynamicTypeSize(.accessibility2)
}
#endif
