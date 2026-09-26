import SwiftUI

struct IllustratedMessage<Actions: View>: View {
    enum Prominence {
        case regular
        case large
    }

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let illustration: EmptyStateIllustration.Kind
    private let prominence: Prominence
    private let actions: Actions

    init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource,
        illustration: EmptyStateIllustration.Kind,
        prominence: Prominence = .regular,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.message = message
        self.illustration = illustration
        self.prominence = prominence
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            EmptyStateIllustration(illustration)
                .frame(height: illustration.height)
            texts
            actions
                .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
    }

    private var texts: some View {
        VStack(spacing: Spacing.sm) {
            Text(title)
                .font(prominence.titleFont)
                .foregroundStyle(.textPrimary)
            Text(message)
                .font(prominence.messageFont)
                .foregroundStyle(.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

extension IllustratedMessage where Actions == EmptyView {
    init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource,
        illustration: EmptyStateIllustration.Kind,
        prominence: Prominence = .regular
    ) {
        self.title = title
        self.message = message
        self.illustration = illustration
        self.prominence = prominence
        self.actions = EmptyView()
    }
}

extension IllustratedMessage.Prominence {
    fileprivate var titleFont: Font {
        switch self {
        case .regular: .bodyEmphasized
        case .large: .title3Emphasized
        }
    }

    fileprivate var messageFont: Font {
        switch self {
        case .regular: .footnote
        case .large: .subheadline
        }
    }
}

private struct IllustratedMessageSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            IllustratedMessage(
                "¡Vaya! Parece que aún no tienes estaciones favoritas…",
                message: "Toca la estrella de cualquier estación y las tendrás siempre a mano.",
                illustration: .noFavorites
            ) {
                Button("Añade una estación") {}
                    .buttonStyle(.railGlass(.tinted))
                    .controlSize(.small)
            }
            IllustratedMessage(
                "Sin resultados para «Sevilla»",
                message: "Revisa la ortografía o busca por línea.",
                illustration: .noResults,
                prominence: .large
            )
        }
        .frame(width: 360)
        .padding(.horizontal, ScreenLayout.margin)
    }
}

#Preview("Variantes Figma") {
    ScrollView {
        IllustratedMessageSamples()
    }
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    ScrollView {
        IllustratedMessageSamples()
    }
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        IllustratedMessageSamples()
    }
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
