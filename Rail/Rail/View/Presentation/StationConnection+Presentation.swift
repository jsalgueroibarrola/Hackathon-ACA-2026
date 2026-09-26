//
//  StationConnection+Presentation.swift
//  Rail
//
//  Created by jakuru on 21/09/2026.
//

import SwiftUI

extension StationConnection {
    var displayName: LocalizedStringResource {
        switch self {
        case .airport: "Aeropuerto"
        case .ave: "AVE"
        case .busStation: "Estación de autobuses"
        case .interurbanBus: "Autobús interurbano"
        case .metro: "Metro"
        case .regional: "Regional"
        case .urbanBus: "Autobús urbano"
        }
    }

    var symbolName: String {
        switch self {
        case .airport: "airplane"
        case .ave: "train.side.front.car"
        case .busStation: "bus.doubledecker.fill"
        case .interurbanBus: "bus.fill"
        case .metro: "tram.fill.tunnel"
        case .regional: "train.side.rear.car"
        case .urbanBus: "bus"
        }
    }

    var tint: Color {
        switch self {
        case .airport: .indigo
        case .ave: .purple
        case .busStation: .brown
        case .interurbanBus: .orange
        case .metro: .green
        case .regional: .teal
        case .urbanBus: Color(red: 0.76, green: 0.56, blue: 0.0)
        }
    }
}


enum StationAccessibilitySymbol {
    static let reducedMobility = "figure.roll"
    static let elevator = "arrow.up.arrow.down"
}
