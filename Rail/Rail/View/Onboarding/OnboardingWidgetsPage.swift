import SwiftData
import SwiftUI

struct OnboardingWidgetsPage: View {
    private let onContinue: () -> Void

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    var body: some View {
        OnboardingFeaturePage(actions: OnboardingActionBar(primary: .continue(onContinue))) {
            OnboardingArtwork(.widgets)
        } content: {
            VStack(spacing: Spacing.xl) {
                OnboardingHeader(Self.title, message: Self.message)
                OnboardingFootnote(Self.howTo)
            }
        }
    }

    private static let title = LocalizedStringResource(
        "Tus trenes, en la pantalla de inicio",
        comment: "Bienvenida, paso del widget: título que presenta el widget de próximos trenes."
    )

    private static let message = LocalizedStringResource(
        "Con el widget de Rail verás las próximas salidas de tu estación favorita sin abrir la app.",
        comment: "Bienvenida, paso del widget: explica qué muestra el widget."
    )

    private static let howTo = LocalizedStringResource(
        "Mantén pulsada la pantalla de inicio, toca Editar › Añadir widget y busca Rail.",
        comment: "Bienvenida, paso del widget: instrucciones para añadir el widget. «Editar» y «Añadir widget» son los botones de iOS; «Rail» es el nombre de la app."
    )
}

#if DEBUG
#Preview("Variantes Figma", traits: .nextTrainsSampleData) {
    OnboardingWidgetsPage {}
        .background(.bgSecondary)
}

#Preview("Descargando") {
    OnboardingWidgetsPage {}
        .background(.bgSecondary)
        .modelContainer(for: RailSchema.models, inMemory: true)
}

#Preview("Modo oscuro", traits: .nextTrainsSampleData) {
    OnboardingWidgetsPage {}
        .background(.bgSecondary)
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type", traits: .nextTrainsSampleData) {
    OnboardingWidgetsPage {}
        .background(.bgSecondary)
        .dynamicTypeSize(.accessibility2)
}
#endif
