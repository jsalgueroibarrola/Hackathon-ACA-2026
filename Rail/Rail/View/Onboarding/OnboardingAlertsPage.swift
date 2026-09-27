import SwiftUI

struct OnboardingAlertsPage: View {
    private let onContinue: () -> Void

    private static let kinds: [AlertKind] = [.notice, .info]

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    var body: some View {
        OnboardingFeaturePage(actions: OnboardingActionBar(primary: .continue(onContinue))) {
            OnboardingArtwork(.alerts)
        } content: {
            VStack(spacing: Spacing.xl) {
                OnboardingHeader(Self.title, message: Self.message)
                HStack(spacing: Spacing.sm) {
                    ForEach(Self.kinds, id: \.self) { kind in
                        SeverityBadge(kind.severity, label: kind.badgeLabel)
                    }
                }
                OnboardingFootnote(Self.footnote)
            }
        }
    }

    private static let title = LocalizedStringResource(
        "Entérate de cada incidencia",
        comment: "Bienvenida, paso de avisos: título que presenta la pantalla de avisos de Renfe."
    )

    private static let message = LocalizedStringResource(
        "Toca la campana de Inicio para ver los avisos que publica Renfe: obras, cambios en el servicio o ascensores fuera de servicio.",
        comment: "Bienvenida, paso de avisos: explica que la campana de Inicio abre los avisos de Renfe y qué tipo de avisos hay."
    )

    private static let footnote = LocalizedStringResource(
        "Renfe publica los avisos solo en español. Si usas otro idioma, podrás traducirlos con un toque.",
        comment: "Bienvenida, paso de avisos: nota al pie sobre el idioma de los avisos y el botón «Traducir»."
    )
}

#if DEBUG
#Preview("Variantes Figma") {
    OnboardingAlertsPage {}
        .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    OnboardingAlertsPage {}
        .background(.bgSecondary)
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    OnboardingAlertsPage {}
        .background(.bgSecondary)
        .dynamicTypeSize(.accessibility2)
}
#endif
