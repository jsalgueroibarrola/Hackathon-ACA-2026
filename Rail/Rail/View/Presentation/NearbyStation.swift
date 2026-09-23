import CoreLocation
import Foundation
import MapKit

extension Station {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct NearbyStation: Identifiable, Equatable {
    let station: Station
    let distance: Measurement<UnitLength>

    var id: String { station.id }
}

extension NearbyStation {
    static func closest(
        to location: UserLocation,
        among stations: [Station],
        limit: Int
    ) -> [NearbyStation] {
        closest(to: location.coordinate, among: stations, limit: limit)
    }

    static func closest(
        to coordinate: CLLocationCoordinate2D,
        among stations: [Station],
        limit: Int
    ) -> [NearbyStation] {
        let origin = MKMapPoint(coordinate)
        return Array(
            stations
                .map {
                    NearbyStation(
                        station: $0,
                        distance: Measurement(
                            value: origin.distance(to: MKMapPoint($0.coordinate)),
                            unit: .meters
                        )
                    )
                }
                .sorted { $0.distance < $1.distance }
                .prefix(limit)
        )
    }
}
