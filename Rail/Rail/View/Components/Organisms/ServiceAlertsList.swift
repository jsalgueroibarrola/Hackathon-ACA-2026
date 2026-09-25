import SwiftUI

struct ServiceAlertsList: View {
    let phase: ServiceAlertsPhase
    let translation: AlertTranslation
    let translationLanguage: String?
    let onTranslate: (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgSecondary)
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            ProgressView()
                .controlSize(.large)

        case .unavailable:
            ContentUnavailableView {
                Label(Self.unavailableTitle, systemImage: "wifi.exclamationmark")
            } description: {
                Text(Self.unavailableMessage)
            } actions: {
                Button(Self.retryLabel, action: onRetry)
                    .buttonStyle(.rail(.prominent))
            }

        case .empty:
            ContentUnavailableView(
                Self.emptyTitle,
                systemImage: "checkmark.circle",
                description: Text(Self.emptyMessage)
            )

        case .content(let items):
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    if let translationLanguage {
                        AlertBanner(
                            .info,
                            title: String(localized: Self.bannerTitle),
                            message: String(
                                localized: Self.bannerMessage(translationLanguage)
                            )
                        )
                    }
                    ForEach(items) { item in
                        card(for: item, state: translation.state(for: item))
                    }
                }
                .padding(.horizontal, ScreenLayout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, ScreenLayout.margin)
            }
        }
    }

    private func card(
        for item: ServiceAlertItem,
        state: AlertTranslation.State
    ) -> some View {
        IncidentCard(item, description: state.text ?? item.text) {
            if translationLanguage != nil {
                Button(state.buttonLabel, systemImage: state.buttonSymbol) {
                    onTranslate(item.id)
                }
                .disabled(state == .translating)
            }
        }
        .animation(.smooth, value: state)
    }

    private static let bannerTitle = LocalizedStringResource(
        "Los avisos se publican en español",
        comment:
            "Notificaciones: título de la banda que aparece cuando el idioma del dispositivo no es el español."
    )

    private static func bannerMessage(_ language: String) -> LocalizedStringResource {
        LocalizedStringResource(
            "Renfe solo ofrece esta información en español. Pulsa Traducir en un aviso para leerlo en \(language).",
            comment:
                "Notificaciones: texto de la banda de idioma. La variable es el nombre del idioma del dispositivo en minúscula, por ejemplo «inglés». «Traducir» es el botón de cada tarjeta."
        )
    }

    private static let unavailableTitle = LocalizedStringResource(
        "No se han podido cargar los avisos",
        comment:
            "Notificaciones: título del estado de error cuando no hay avisos guardados y la descarga ha fallado."
    )

    private static let unavailableMessage = LocalizedStringResource(
        "Comprueba la conexión y vuelve a intentarlo.",
        comment:
            "Notificaciones: descripción del estado de error cuando no se han podido descargar los avisos."
    )

    private static let retryLabel = LocalizedStringResource(
        "Reintentar",
        comment: "Botón para volver a intentar una descarga que ha fallado."
    )

    private static let emptyTitle = LocalizedStringResource(
        "Sin avisos",
        comment: "Notificaciones: título del estado vacío cuando Renfe no tiene avisos activos."
    )

    private static let emptyMessage = LocalizedStringResource(
        "No hay incidencias en la red de Cercanías.",
        comment: "Notificaciones: descripción del estado vacío cuando Renfe no tiene avisos activos."
    )
}

extension AlertTranslation.State {
    fileprivate var text: String? {
        switch self {
        case .original, .translating: nil
        case .translated(let text): text
        }
    }

    fileprivate var buttonSymbol: String {
        switch self {
        case .original, .translating: "sparkles"
        case .translated: "arrow.uturn.backward"
        }
    }

    fileprivate var buttonLabel: LocalizedStringResource {
        switch self {
        case .original:
            LocalizedStringResource(
                "Traducir",
                comment:
                    "Notificaciones: botón de una tarjeta que traduce el aviso de Renfe al idioma del dispositivo."
            )
        case .translating:
            LocalizedStringResource(
                "Traduciendo…",
                comment:
                    "Notificaciones: botón desactivado de una tarjeta mientras se traduce el aviso."
            )
        case .translated:
            LocalizedStringResource(
                "Ver original",
                comment:
                    "Notificaciones: botón de una tarjeta traducida que vuelve a mostrar el aviso en español."
            )
        }
    }
}

#if DEBUG
    #Preview("Variantes Figma") {
        ServiceAlertsList(
            phase: .content(ServiceAlertItem.samples),
            translation: AlertTranslation(),
            translationLanguage: nil,
            onTranslate: { _ in },
            onRetry: {}
        )
    }

    #Preview("Otro idioma") {
        ServiceAlertsList(
            phase: .content(ServiceAlertItem.samples),
            translation: .preview,
            translationLanguage: "inglés",
            onTranslate: { _ in },
            onRetry: {}
        )
    }

    #Preview("Sin avisos") {
        ServiceAlertsList(
            phase: .empty,
            translation: AlertTranslation(),
            translationLanguage: nil,
            onTranslate: { _ in },
            onRetry: {}
        )
    }

    #Preview("Sin conexión") {
        ServiceAlertsList(
            phase: .unavailable,
            translation: AlertTranslation(),
            translationLanguage: nil,
            onTranslate: { _ in },
            onRetry: {}
        )
    }

    #Preview("Modo oscuro") {
        ServiceAlertsList(
            phase: .content(ServiceAlertItem.samples),
            translation: .preview,
            translationLanguage: "inglés",
            onTranslate: { _ in },
            onRetry: {}
        )
        .preferredColorScheme(.dark)
    }

    #Preview("Dynamic Type") {
        ServiceAlertsList(
            phase: .content(ServiceAlertItem.samples),
            translation: .preview,
            translationLanguage: "inglés",
            onTranslate: { _ in },
            onRetry: {}
        )
        .dynamicTypeSize(.accessibility2)
    }
#endif
