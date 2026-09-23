import SwiftUI

struct EmptyStateCard<Action: View>: View {
    private static var cornerRadius: CGFloat { 12 }

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let systemImage: String
    private let tint: Color
    private let action: Action

    init(
        _ title: LocalizedStringResource,
        message: LocalizedStringResource,
        systemImage: String,
        tint: Color,
        @ViewBuilder action: () -> Action
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.tint = tint
        self.action = action()
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            texts
            action
                .buttonStyle(.rail(.bordered))
                .controlSize(.regular)
                .padding(.top, Spacing.xs + Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xxl)
        .background(
            .bgPrimary,
            in: .rect(cornerRadius: Self.cornerRadius, style: .continuous)
        )
    }

    private var texts: some View {
        VStack(spacing: Spacing.sm) {
            Text(title)
                .font(.bodyEmphasized)
                .foregroundStyle(.textPrimary)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

private struct EmptyStateCardSamples: View {
    var body: some View {
        EmptyStateCard(
            "Marca tus estaciones habituales",
            message: "Toca la estrella de cualquier estación y la tendrás siempre aquí.",
            systemImage: "star",
            tint: .interactiveFavorite
        ) {
            Button("Ver estaciones") {}
        }
        .frame(width: 360)
        .padding(ScreenLayout.margin)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    EmptyStateCardSamples()
}

#Preview("Modo oscuro") {
    EmptyStateCardSamples()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    ScrollView {
        EmptyStateCardSamples()
    }
    .background(.bgSecondary)
    .dynamicTypeSize(.accessibility2)
}
