import SwiftUI

struct OnboardingActionBar: View {
    struct Action {
        let title: LocalizedStringResource
        let perform: () -> Void
    }

    private let primary: Action
    private let secondary: Action?

    init(primary: Action, secondary: Action? = nil) {
        self.primary = primary
        self.secondary = secondary
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: primary.perform) {
                Text(primary.title)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.railGlass(.tinted))
            if let secondary {
                Button(secondary.title, action: secondary.perform)
                    .buttonStyle(.rail(.borderless))
            }
        }
        .padding(.vertical, Spacing.sm)
        .onboardingColumn()
    }
}

extension OnboardingActionBar.Action {
    static func start(_ perform: @escaping () -> Void) -> Self {
        Self(title: startLabel, perform: perform)
    }

    static func `continue`(_ perform: @escaping () -> Void) -> Self {
        Self(title: continueLabel, perform: perform)
    }

    private static let startLabel = LocalizedStringResource(
        "Empezar",
        comment: "Bienvenida: botón principal del primer paso, que empieza la bienvenida, y del último, que la termina y abre la app."
    )

    private static let continueLabel = LocalizedStringResource(
        "Continuar",
        comment: "Bienvenida: botón principal que pasa al siguiente paso."
    )
}
