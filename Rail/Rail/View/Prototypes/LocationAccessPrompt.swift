import SwiftUI
import UIKit

struct LocationAccessPrompt: View {
    let message: LocalizedStringKey

    @Environment(LocationViewModel.self) private var location
    @Environment(\.openURL) private var openURL

    var body: some View {
        if location.canRequestAccess {
            prompt(
                message: message,
                action: "Usar mi ubicación",
                icon: "location"
            ) {
                location.requestAccess()
            }
        } else if location.isAccessBlocked {
            prompt(
                message:
                    "Rail no tiene acceso a tu ubicación. Actívalo en Ajustes para usar esta función.",
                action: "Abrir Ajustes",
                icon: "gear"
            ) {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                openURL(url)
            }
        }
    }

    private func prompt(
        message: LocalizedStringKey,
        action: LocalizedStringKey,
        icon: String,
        perform: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
            Button(action, systemImage: icon, action: perform)
                .buttonStyle(.rail(.bordered))
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Previews

#Preview("Sin permiso") {
    List {
        Section("Cerca de ti") {
            LocationAccessPrompt(
                message:
                    "Activa la ubicación para ver qué estaciones tienes más cerca y a qué distancia están."
            )
        }
    }
    .environment(LocationViewModel.preview(authorization: .notDetermined))
}

#Preview("Permiso denegado") {
    List {
        Section("Cerca de ti") {
            LocationAccessPrompt(
                message:
                    "Activa la ubicación para ver qué estaciones tienes más cerca y a qué distancia están."
            )
        }
    }
    .environment(LocationViewModel.preview(authorization: .denied))
}
