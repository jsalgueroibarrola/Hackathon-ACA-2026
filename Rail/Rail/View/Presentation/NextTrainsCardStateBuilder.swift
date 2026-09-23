import CoreLocation
import Foundation

enum NextTrainsCardStateBuilder {
    static let nearbyRadius = Measurement<UnitLength>(
        value: 10,
        unit: .kilometers
    )
    static let visibleDepartures = 2
    static let walkingLimit: Duration = .seconds(3600)

    static func target(
        authorization: LocationAuthorization,
        location: UserLocation?,
        hasLocationFailed: Bool,
        savedLocation: SavedLocation?,
        stations: [Station],
        nearbyRadius: Measurement<UnitLength> = nearbyRadius
    ) -> NextTrainsTarget {
        let nearest = location.flatMap {
            NearbyStation.closest(to: $0, among: stations, limit: 1).first
        }
        let saved = savedLocation.flatMap {
            station(for: $0, among: stations)
        }

        return if let nearest, nearest.distance <= nearbyRadius {
            .station(
                nearest.station,
                source: .device(distance: nearest.distance)
            )
        } else if let saved {
            .station(saved, source: .saved)
        } else if let nearest {
            .noStationNearby(nearest)
        } else {
            fallback(
                authorization: authorization,
                hasLocationFailed: hasLocationFailed
            )
        }
    }

    static func departures(
        from schedules: NextTrainsSchedules,
        now: Date,
        timeZone: TimeZone,
        limit: Int = visibleDepartures
    ) -> NextTrainsDepartures {
        let format = Date.FormatStyle.departureTime(in: timeZone)
        let rows = schedules.today
            .flatMap { line in
                line.upcoming(from: now).map { (line: line, departure: $0) }
            }
            .sorted {
                ($0.departure.date, $0.line.lineID)
                    < ($1.departure.date, $1.line.lineID)
            }
            .prefix(limit)
            .map {
                NextTrainsDeparture(
                    id: $0.departure.id,
                    line: $0.line.lineID,
                    colorHex: $0.line.colorHex,
                    destination: $0.line.destination,
                    time: $0.departure.date.formatted(format)
                )
            }

        return rows.isEmpty
            ? .finished(
                firstTomorrow: schedules.tomorrow
                    .flatMap(\.departures)
                    .map(\.date)
                    .min()
                    .map { $0.formatted(format) }
            )
            : .upcoming(rows)
    }

    static func proximity(
        source: NextTrainsTarget.Source,
        walking: TravelEstimate?
    ) -> NextTrainsProximity {
        switch source {
        case .saved:
            .saved
        case .device(let distance):
            if let walking, walking.travelTime < walkingLimit {
                .walking(minutes: minutes(walking.travelTime))
            } else {
                .distance(distance.distanceLabel)
            }
        }
    }

    static func state(
        target: NextTrainsTarget,
        schedules: NextTrainsSchedules?,
        walking: WalkingResult?,
        now: Date,
        timeZone: TimeZone
    ) -> NextTrainsCardState {
        switch target {
        case .locating:
            .locating
        case .permissionNeeded:
            .permissionNeeded
        case .permissionDenied:
            .permissionDenied
        case .locationUnavailable:
            .locationUnavailable
        case .noStationNearby(let nearest):
            .noStationNearby(
                name: nearest.station.name,
                distance: kilometers(nearest.distance)
            )
        case .station(let station, let source):
            .station(
                NextTrainsStation(
                    name: station.name,
                    proximity: proximity(
                        source: source,
                        walking: walking.flatMap {
                            $0.request.stationID == station.id
                                ? $0.estimate : nil
                        }
                    ),
                    departures: schedules.flatMap {
                        $0.stationID == station.id
                            ? departures(from: $0, now: now, timeZone: timeZone)
                            : nil
                    } ?? .loading
                )
            )
        }
    }

    private static func minutes(_ travelTime: Duration) -> Int {
        max(1, Int((travelTime / .seconds(60)).rounded(.up)))
    }

    private static func kilometers(_ distance: Measurement<UnitLength>)
        -> String
    {
        distance.converted(to: .kilometers)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .asProvided,
                    numberFormatStyle: .number.precision(.fractionLength(0))
                )
            )
    }

    private static func station(
        for saved: SavedLocation,
        among stations: [Station]
    ) -> Station? {
        stations.first { $0.id == saved.stationID }
            ?? NearbyStation.closest(
                to: saved.coordinate,
                among: stations,
                limit: 1
            ).first?.station
    }

    private static func fallback(
        authorization: LocationAuthorization,
        hasLocationFailed: Bool
    ) -> NextTrainsTarget {
        switch authorization {
        case .notDetermined:
            .permissionNeeded
        case .denied, .restricted:
            .permissionDenied
        case .authorized:
            hasLocationFailed ? .locationUnavailable : .locating
        }
    }
}
