import SwiftUI

struct OnboardingLocationPage: View {
    private let onContinue: () -> Void

    @Environment(LocationViewModel.self) private var location

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    private var actions: OnboardingActionBar {
        location.canRequestAccess
            ? OnboardingActionBar(
                primary: .init(title: Self.allowLabel) { location.requestAccess() },
                secondary: .init(title: Self.notNowLabel, perform: onContinue)
            )
            : OnboardingActionBar(primary: .continue(onContinue))
    }

    var body: some View {
        OnboardingFeaturePage(actions: actions) {
            OnboardingArtwork(.location)
        } content: {
            OnboardingHeader(
                Self.title,
                message: Self.message,
                spacing: Spacing.xxl
            )
        }
    }

    private static let title = LocalizedStringResource(
        "Tu estación más cercana, siempre a mano",
        comment: "Bienvenida, paso 3: título antes de pedir permiso de ubicación."
    )

    private static let message = LocalizedStringResource(
        "Con tu ubicación te enseñamos las próximas salidas de la estación en la que estás.",
        comment: "Bienvenida, paso 3: explica para qué se usa la ubicación antes de que iOS pida el permiso."
    )

    private static let allowLabel = LocalizedStringResource(
        "Permitir ubicación",
        comment: "Botón que pide a iOS el permiso de ubicación."
    )

    private static let notNowLabel = LocalizedStringResource(
        "Ahora no",
        comment: "Bienvenida, paso 3: botón secundario que salta el permiso de ubicación sin pedirlo."
    )
}

#if DEBUG
#Preview("Variantes Figma") {
    OnboardingLocationPage {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .notDetermined))
}

#Preview("Permiso ya decidido") {
    OnboardingLocationPage {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .denied))
}

#Preview("Modo oscuro") {
    OnboardingLocationPage {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .notDetermined))
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    OnboardingLocationPage {}
        .background(.bgSecondary)
        .environment(LocationViewModel.preview(authorization: .notDetermined))
        .dynamicTypeSize(.accessibility2)
}
#endif
