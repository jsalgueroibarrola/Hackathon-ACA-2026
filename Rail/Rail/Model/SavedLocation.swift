import CoreLocation
import Foundation

struct SavedLocation: Hashable, Sendable {
    let stationID: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension SavedLocation {
    init(station: Station) {
        self.init(
            stationID: station.id,
            latitude: station.latitude,
            longitude: station.longitude
        )
    }

    init(_ saved: SavedStation) {
        self.init(
            stationID: saved.stationID,
            latitude: saved.latitude,
            longitude: saved.longitude
        )
    }
}
