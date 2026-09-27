import SwiftUI

struct OnboardingPrivacyPage: View {
    private let onContinue: () -> Void

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    var body: some View {
        OnboardingFeaturePage(actions: OnboardingActionBar(primary: .continue(onContinue))) {
            OnboardingArtwork(.privacy)
        } content: {
            VStack(spacing: Spacing.xl) {
                OnboardingHeader(Self.title, message: Self.message)
                SeverityBadge(.resolved, label: Self.badge)
                OnboardingFootnote(Self.footnote)
            }
        }
    }

    private static let title = LocalizedStringResource(
        "Sin cuentas, sin contraseñas",
        comment: "Bienvenida, paso 2: título que explica que la app no pide registrarse."
    )

    private static let message = LocalizedStringResource(
        "Tus estaciones favoritas y búsquedas recientes se guardan en tu dispositivo. No hay nada que crear ni que recordar.",
        comment: "Bienvenida, paso 2: explica que los datos del usuario se quedan en el dispositivo."
    )

    private static let badge = LocalizedStringResource(
        "Guardado en tu dispositivo",
        comment: "Bienvenida, paso 2: etiqueta verde con una marca de verificación."
    )

    private static let footnote = LocalizedStringResource(
        "Si eliminas la app, se borrarán tus favoritas y búsquedas recientes.",
        comment: "Bienvenida, paso 2: aviso al pie de que desinstalar la app borra los datos guardados."
    )
}

#if DEBUG
#Preview("Variantes Figma") {
    OnboardingPrivacyPage {}
        .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    OnboardingPrivacyPage {}
        .background(.bgSecondary)
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    OnboardingPrivacyPage {}
        .background(.bgSecondary)
        .dynamicTypeSize(.accessibility2)
}
#endif
