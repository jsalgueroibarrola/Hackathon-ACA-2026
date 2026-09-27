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
