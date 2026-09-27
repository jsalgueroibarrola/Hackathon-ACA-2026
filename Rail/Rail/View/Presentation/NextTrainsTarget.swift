import Foundation

enum NextTrainsTarget: Equatable {
    enum Source: Equatable {
        case device(distance: Measurement<UnitLength>)
        case saved
    }

    case locating
    case permissionNeeded
    case permissionDenied
    case locationUnavailable
    case noStationNearby(NearbyStation)
    case station(Station, source: Source)

    var station: Station? {
        switch self {
        case .station(let station, _):
            station
        case .locating, .permissionNeeded, .permissionDenied,
            .locationUnavailable, .noStationNearby:
            nil
        }
    }
}
