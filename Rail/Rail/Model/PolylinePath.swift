import MapKit

struct PolylinePath: Sendable {
    let coordinates: [CLLocationCoordinate2D]
    private let cumulative: [CLLocationDistance]

    init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        self.cumulative = zip(coordinates, coordinates.dropFirst())
            .reduce(into: coordinates.isEmpty ? [] : [0]) { total, segment in
                total.append(
                    total[total.count - 1]
                        + MKMapPoint(segment.0).distance(
                            to: MKMapPoint(segment.1)
                        )
                )
            }
    }

    var isEmpty: Bool { coordinates.isEmpty }

    var length: CLLocationDistance { cumulative.last ?? 0 }

    func distance(projecting coordinate: CLLocationCoordinate2D)
        -> CLLocationDistance?
    {
        guard coordinates.count > 1 else {
            return coordinates.isEmpty ? nil : 0
        }
        let target = MKMapPoint(coordinate)
        return coordinates.indices.dropLast()
            .map { index in projection(of: target, onSegment: index) }
            .min { $0.offset < $1.offset }?
            .along
    }

    func coordinate(at distance: CLLocationDistance) -> CLLocationCoordinate2D {
        guard let (index, fraction) = segment(at: distance) else {
            return coordinates.first ?? CLLocationCoordinate2D()
        }
        let start = MKMapPoint(coordinates[index])
        let end = MKMapPoint(coordinates[index + 1])
        return MKMapPoint(
            x: start.x + (end.x - start.x) * fraction,
            y: start.y + (end.y - start.y) * fraction
        ).coordinate
    }

    func bearing(at distance: CLLocationDistance, reversed: Bool = false)
        -> CLLocationDirection
    {
        guard let (index, _) = segment(at: distance) else { return 0 }
        let forward = Self.bearing(
            from: coordinates[index],
            to: coordinates[index + 1]
        )
        return reversed
            ? (forward + 180).truncatingRemainder(dividingBy: 360) : forward
    }

    private func segment(at distance: CLLocationDistance) -> (
        index: Int, fraction: Double
    )? {
        guard coordinates.count > 1 else { return nil }
        let clamped = min(max(distance, 0), length)
        let index = min(
            cumulative.lastIndex { $0 <= clamped } ?? 0,
            coordinates.count - 2
        )
        let span = cumulative[index + 1] - cumulative[index]
        return (index, span > 0 ? (clamped - cumulative[index]) / span : 0)
    }

    private func projection(
        of target: MKMapPoint,
        onSegment index: Int
    ) -> (along: CLLocationDistance, offset: CLLocationDistance) {
        let start = MKMapPoint(coordinates[index])
        let end = MKMapPoint(coordinates[index + 1])
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy
        let fraction =
            lengthSquared > 0
            ? min(
                max(
                    ((target.x - start.x) * dx + (target.y - start.y) * dy)
                        / lengthSquared,
                    0
                ),
                1
            )
            : 0
        let closest = MKMapPoint(
            x: start.x + dx * fraction,
            y: start.y + dy * fraction
        )
        return (
            cumulative[index] + (cumulative[index + 1] - cumulative[index])
                * fraction,
            closest.distance(to: target)
        )
    }

    private static func bearing(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> CLLocationDirection {
        let startLatitude = start.latitude * .pi / 180
        let endLatitude = end.latitude * .pi / 180
        let deltaLongitude = (end.longitude - start.longitude) * .pi / 180
        let y = sin(deltaLongitude) * cos(endLatitude)
        let x =
            cos(startLatitude) * sin(endLatitude)
            - sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)
        let degrees = atan2(y, x) * 180 / .pi
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}
