import CoreLocation

struct RouteEstimateRequest: Sendable, Identifiable {
    struct ID: Hashable, Sendable {
        let origin: LocationCell
        let stationID: String
        let modes: [TravelMode]
        let attempt: Int
    }

    let id: ID
    let origin: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D

    init(
        from location: UserLocation,
        to station: Station,
        modes: [TravelMode],
        attempt: Int = 0
    ) {
        id = ID(
            origin: location.cell,
            stationID: station.id,
            modes: modes,
            attempt: attempt
        )
        origin = location.coordinate
        destination = station.coordinate
    }
}

struct RouteEstimates: Sendable {
    let requestID: RouteEstimateRequest.ID
    let values: [TravelMode: TravelEstimate]

    func estimate(_ mode: TravelMode, to stationID: String) -> TravelEstimate? {
        requestID.stationID == stationID ? values[mode] : nil
    }
}
