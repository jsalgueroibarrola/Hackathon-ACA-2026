import Foundation

extension AlertKind {
    var severity: IncidentSeverity {
        switch self {
        case .notice: .warning
        case .info, .other: .info
        }
    }

    var badgeLabel: LocalizedStringResource {
        switch self {
        case .notice:
            LocalizedStringResource(
                "Aviso",
                comment: "Gravedad de una incidencia: aviso informativo"
            )
        case .info, .other:
            LocalizedStringResource(
                "Info",
                comment:
                    "Notificaciones: etiqueta del badge de un aviso informativo de Renfe. Abreviatura de «Información»."
            )
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .notice:
            LocalizedStringResource(
                "Aviso en la red",
                comment:
                    "Notificaciones: título de la tarjeta de un aviso de Renfe sobre una incidencia en curso. Debajo va el texto del aviso."
            )
        case .info, .other:
            LocalizedStringResource(
                "Información de la red",
                comment:
                    "Notificaciones: título de la tarjeta de un aviso informativo de Renfe. Debajo va el texto del aviso."
            )
        }
    }
}
