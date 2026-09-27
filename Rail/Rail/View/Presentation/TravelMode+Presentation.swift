import Foundation

extension TravelMode {
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
