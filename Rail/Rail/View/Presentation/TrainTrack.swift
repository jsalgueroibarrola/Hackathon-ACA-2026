import CoreLocation
import Foundation

struct TrainPosition: Sendable {
    let coordinate: CLLocationCoordinate2D
    let bearing: CLLocationDirection
}

struct TrainTrack: Identifiable, Sendable {
    static let nominalSpeed: CLLocationSpeed = 50 / 3.6
    static let maximumExtrapolation: TimeInterval = 90
    static let maximumAge: TimeInterval = 300
    static let approachDistance: CLLocationDistance = 400

    let id: String
    let lineID: String
    let colorHex: String
    let train: String
    let direction: TripDirection
    let headsign: String?
    let delaySeconds: Int?
    let status: LiveStatus
    let sampledAt: Date
    let path: PolylinePath
    let startDistance: CLLocationDistance
    let endDistance: CLLocationDistance
    var positionSampledAt: Date?

    func position(at date: Date) -> TrainPosition {
        let anchor = positionSampledAt ?? sampledAt
        let horizon = sampledAt.addingTimeInterval(Self.maximumExtrapolation)
        let elapsed = max(min(date, horizon).timeIntervalSince(anchor), 0)
        let sign: Double = direction == .outbound ? 1 : -1
        let gap = max((endDistance - startDistance) * sign, 0)
        let travelled = status == .at ? 0 : min(Self.nominalSpeed * elapsed, gap)
        let distance = startDistance + travelled * sign
        return TrainPosition(
            coordinate: path.coordinate(at: distance),
            bearing: path.bearing(at: distance, reversed: direction == .inbound)
        )
    }

    func isStale(at date: Date) -> Bool {
        date.timeIntervalSince(sampledAt) > Self.maximumExtrapolation
    }

    func isExpired(at date: Date) -> Bool {
        date.timeIntervalSince(sampledAt) > Self.maximumAge
    }

    var accessibilityLabel: String {
        [
            headsign.map {
                String(
                    localized: "Tren \(train) de la línea \(lineID) hacia \($0)",
                    comment: "Mapa: descripción para VoiceOver de un tren en tiempo real, con su número, su línea y su destino."
                )
            } ?? String(
                localized: "Tren \(train) de la línea \(lineID)",
                comment: "Mapa: descripción para VoiceOver de un tren en tiempo real cuyo destino se desconoce."
            ),
            delayMinutes.map {
                String(
                    localized: "con \($0) minutos de retraso",
                    comment: "Mapa: retraso de un tren en tiempo real, leído por VoiceOver tras su descripción y una coma, por ejemplo «con 3 minutos de retraso»."
                )
            },
        ]
        .compactMap(\.self)
        .joined(separator: ", ")
    }

    private var delayMinutes: Int? {
        delaySeconds.map { $0 / 60 }.flatMap { $0 > 0 ? $0 : nil }
    }
}

enum TrainTrackBuilder {
    static func tracks(
        trains: [LiveTrain],
        lines: [Line],
        paths: [String: PolylinePath],
        fetchedAt: Date
    ) -> [TrainTrack] {
        let linesByID = Dictionary(
            lines.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return trains.compactMap { train in
            guard let line = linesByID[train.lineID],
                  let path = paths[train.lineID],
                  !path.isEmpty
            else { return nil }
            return track(for: train, on: line, path: path, fetchedAt: fetchedAt)
        }
    }

    private static func track(
        for train: LiveTrain,
        on line: Line,
        path: PolylinePath,
        fetchedAt: Date
    ) -> TrainTrack? {
        let stops = line.orderedStops
        let sequences = Dictionary(
            stops.map { ($0.stationID, $0.sequence) },
            uniquingKeysWith: { first, _ in first }
        )
        let stations = Dictionary(
            stops.compactMap { stop in stop.station.map { (stop.stationID, $0) } },
            uniquingKeysWith: { first, _ in first }
        )
        let current = train.stopID.flatMap { stations[$0] }
        let next = train.nextStopID.flatMap { stations[$0] }

        let reported = train.latitude.flatMap { latitude in
            train.longitude.map {
                CLLocationCoordinate2D(latitude: latitude, longitude: $0)
            }
        }
        let reportedDistance = reported.flatMap(path.distance(projecting:))
        let currentDistance = current.flatMap { path.distance(projecting: $0.coordinate) }
        let nextDistance = next.flatMap { path.distance(projecting: $0.coordinate) }

        guard let direction = train.direction
            ?? direction(
                from: train.stopID.flatMap { sequences[$0] },
                to: train.nextStopID.flatMap { sequences[$0] }
            )
            ?? direction(from: reportedDistance ?? currentDistance, to: nextDistance)
        else { return nil }

        let sign: Double = direction == .outbound ? 1 : -1
        let approachDistance = train.status == .approaching
            ? nextDistance.map { min(max($0 - TrainTrack.approachDistance * sign, 0), path.length) }
            : nil
        guard let startDistance = reportedDistance ?? approachDistance ?? currentDistance ?? nextDistance
        else { return nil }
        let endDistance = nextDistance ?? (direction == .outbound ? path.length : 0)

        return TrainTrack(
            id: "\(train.lineID)-\(train.train)",
            lineID: train.lineID,
            colorHex: line.colorHex,
            train: train.train,
            direction: direction,
            headsign: line.orderedStops(for: direction).last?.station?.name,
            delaySeconds: train.delaySeconds,
            status: train.status,
            sampledAt: train.sampledAt ?? fetchedAt,
            path: path,
            startDistance: startDistance,
            endDistance: endDistance,
            positionSampledAt: train.positionSampledAt
        )
    }

    static func direction<Position: Comparable>(
        from current: Position?,
        to next: Position?
    ) -> TripDirection? {
        guard let current, let next, current != next else { return nil }
        return next > current ? .outbound : .inbound
    }
}
