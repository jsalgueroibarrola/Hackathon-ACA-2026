import CoreLocation
import Foundation
import MapKit

struct UserLocation: Sendable, Hashable {
    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: CLLocationDistance
    let timestamp: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distance(to coordinate: CLLocationCoordinate2D) -> Measurement<
        UnitLength
    > {
        Measurement(
            value: MKMapPoint(self.coordinate)
                .distance(to: MKMapPoint(coordinate)),
            unit: .meters
        )
    }
}

extension UserLocation {
    init(_ location: CLLocation) {
        self.init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            timestamp: location.timestamp
        )
    }

    var cell: LocationCell { coordinate.cell }
}

struct LocationCell: Sendable, Hashable {
    let latitude: Int
    let longitude: Int
}

extension CLLocationCoordinate2D {
    static let cellsPerDegree: Double = 2000

    var cell: LocationCell {
        LocationCell(
            latitude: Int((latitude * Self.cellsPerDegree).rounded()),
            longitude: Int((longitude * Self.cellsPerDegree).rounded())
        )
    }
}

enum LocationAuthorization: Sendable, Hashable {
    case notDetermined
    case denied
    case restricted
    case authorized

    init(_ status: CLAuthorizationStatus) {
        self =
            switch status {
            case .notDetermined: .notDetermined
            case .denied: .denied
            case .restricted: .restricted
            case .authorizedAlways, .authorizedWhenInUse: .authorized
            @unknown default: .notDetermined
            }
    }

    var isBlocked: Bool {
        self == .denied || self == .restricted
    }
}

enum LocationEvent: Sendable, Hashable {
    case authorization(LocationAuthorization)
    case reading(UserLocation)
    case unavailable
}

extension Measurement<UnitLength> {
    var distanceLabel: String {
        let meters = converted(to: .meters).value
        return meters < 1000
            ? Measurement(value: meters.rounded(), unit: UnitLength.meters)
                .formatted(
                    .measurement(width: .abbreviated, usage: .asProvided)
                )
            : converted(to: .kilometers)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .asProvided,
                        numberFormatStyle: .number.precision(.fractionLength(1))
                    )
                )
    }
}
