import Foundation

enum StationProximity: Hashable, Sendable {
    case permissionNeeded
    case locating
    case away(NextTrainsProximity)
    case unknown
}

enum StationSummaryBuilder {
    static func proximity(
        authorization: LocationAuthorization,
        distance: Measurement<UnitLength>?,
        hasLocationFailed: Bool,
        walking: TravelEstimate?
    ) -> StationProximity {
        switch (authorization, distance) {
        case (.notDetermined, _):
            .permissionNeeded
        case (.denied, _), (.restricted, _):
            .unknown
        case (.authorized, let distance?):
            .away(
                NextTrainsCardStateBuilder.proximity(
                    source: .device(distance: distance),
                    walking: walking
                )
            )
        case (.authorized, nil):
            hasLocationFailed ? .unknown : .locating
        }
    }

    static func walkingRequest(
        from location: UserLocation?,
        to station: Station,
        radius: Measurement<UnitLength> = NextTrainsCardStateBuilder
            .nearbyRadius
    ) -> RouteEstimateRequest? {
        location.flatMap {
            $0.distance(to: station.coordinate) <= radius
                ? RouteEstimateRequest(from: $0, to: station, modes: [.walking])
                : nil
        }
    }
}
