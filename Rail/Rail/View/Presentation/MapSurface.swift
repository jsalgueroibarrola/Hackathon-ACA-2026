import MapKit
import SwiftUI

enum MapSurface: String, CaseIterable, Identifiable {
    case standard
    case muted
    case hybrid
    case imagery

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .standard:
            LocalizedStringResource("Estándar", comment: "Mapa: estilo de mapa estándar.")
        case .muted:
            LocalizedStringResource("Atenuado", comment: "Mapa: estilo de mapa con colores apagados y sin puntos de interés.")
        case .hybrid:
            LocalizedStringResource("Híbrido", comment: "Mapa: estilo de mapa con satélite y calles.")
        case .imagery:
            LocalizedStringResource("Satélite", comment: "Mapa: estilo de mapa con imágenes de satélite.")
        }
    }

    var mapStyle: MapStyle {
        switch self {
        case .standard:
            .standard(elevation: .flat)
        case .muted:
            .standard(
                elevation: .flat,
                emphasis: .muted,
                pointsOfInterest: .excludingAll
            )
        case .hybrid:
            .hybrid(elevation: .realistic, pointsOfInterest: .excludingAll)
        case .imagery:
            .imagery(elevation: .realistic)
        }
    }
}
