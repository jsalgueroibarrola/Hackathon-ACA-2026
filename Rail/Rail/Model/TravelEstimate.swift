import Foundation
import MapKit

enum TravelMode: String, Sendable, Hashable, CaseIterable, Identifiable {
    case walking
    case cycling
    case automobile
    case transit

    var id: String { rawValue }

    var transportType: MKDirectionsTransportType {
        switch self {
        case .walking: .walking
        case .cycling: .cycling
        case .automobile: .automobile
        case .transit: .transit
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .walking: "Andando"
        case .cycling: "En bici"
        case .automobile: "En coche"
        case .transit: "Transporte público"
        }
    }

    var symbolName: String {
        switch self {
        case .walking: "figure.walk"
        case .cycling: "bicycle"
        case .automobile: "car.fill"
        case .transit: "bus.fill"
        }
    }

    var freshness: Duration {
        switch self {
        case .walking, .cycling: .seconds(1800)
        case .automobile, .transit: .seconds(120)
        }
    }

    /// Apple Maps only estimates arrival for `.transit`: it never returns a
    /// geometry or step list, so that mode cannot be drawn on the map.
    var supportsDirections: Bool {
        self != .transit
    }
}

struct TravelEstimate: Sendable, Hashable {
    let mode: TravelMode
    let travelTime: Duration
    let distance: Measurement<UnitLength>
    let departure: Date?
    let arrival: Date?
}

extension TravelEstimate {
    var timeLabel: String { travelTime.travelLabel }

    var departureLabel: String? {
        departure.map {
            $0.formatted(date: .omitted, time: .shortened)
        }
    }
}

extension Duration {
    var travelLabel: String {
        if self < .seconds(60) {
            String(
                localized: "menos de 1 min",
                comment: "Tiempo de viaje cuando la estación está a menos de un minuto."
            )
        } else if self < .seconds(3600) {
            formatted(.units(allowed: [.minutes], width: .abbreviated))
        } else {
            formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        }
    }
}
