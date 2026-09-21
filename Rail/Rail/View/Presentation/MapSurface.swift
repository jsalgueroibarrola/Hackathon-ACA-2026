//
//  MapSurface.swift
//  Rail
//
//  Created by jakuru on 21/09/2026.
//

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
        case .standard: "Estándar"
        case .muted: "Atenuado"
        case .hybrid: "Híbrido"
        case .imagery: "Satélite"
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
