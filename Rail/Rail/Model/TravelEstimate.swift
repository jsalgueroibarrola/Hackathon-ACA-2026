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
        case .walking:
            LocalizedStringResource("Andando", comment: "Cómo llegar: modo de transporte a pie.")
        case .cycling:
            LocalizedStringResource("En bici", comment: "Cómo llegar: modo de transporte en bicicleta.")
        case .automobile:
            LocalizedStringResource("En coche", comment: "Cómo llegar: modo de transporte en coche.")
        case .transit:
            LocalizedStringResource("Transporte público", comment: "Cómo llegar: modo de transporte en transporte público.")
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
