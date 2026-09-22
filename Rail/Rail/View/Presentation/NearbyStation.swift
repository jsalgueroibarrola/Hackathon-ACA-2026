import CoreLocation
import Foundation

extension Station {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct NearbyStation: Identifiable {
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
        Array(
            stations
                .map {
                    NearbyStation(
                        station: $0,
                        distance: location.distance(to: $0.coordinate)
                    )
                }
                .sorted { $0.distance < $1.distance }
                .prefix(limit)
        )
    }
}
