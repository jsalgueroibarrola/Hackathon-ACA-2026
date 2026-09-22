import SwiftUI

enum IncidentSeverity: CaseIterable {
    case info
    case warning
    case critical
    case resolved
}

extension IncidentSeverity {
    var symbol: String {
        switch self {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .critical: "exclamationmark.circle.fill"
        case .resolved: "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .info: .statusInfo
        case .warning: .statusWarning
        case .critical: .statusError
        case .resolved: .statusSuccess
        }
    }

    var background: Color {
        switch self {
        case .info: .statusInfoBg
        case .warning: .statusWarningBg
        case .critical: .statusErrorBg
        case .resolved: .statusSuccessBg
        }
    }

    var foreground: Color {
        switch self {
        case .info: .statusInfoText
        case .warning: .statusWarningText
        case .critical: .statusErrorText
        case .resolved: .statusSuccessText
        }
    }

    var label: LocalizedStringResource {
        switch self {
        case .info:
            LocalizedStringResource(
                "Aviso",
                comment: "Gravedad de una incidencia: aviso informativo"
            )
        case .warning:
            LocalizedStringResource(
                "Retrasos",
                comment: "Gravedad de una incidencia: hay demoras en el servicio"
            )
        case .critical:
            LocalizedStringResource(
                "Interrumpido",
                comment: "Gravedad de una incidencia: servicio interrumpido"
            )
        case .resolved:
            LocalizedStringResource(
                "Resuelto",
                comment: "Gravedad de una incidencia: incidencia cerrada"
            )
        }
    }
}
