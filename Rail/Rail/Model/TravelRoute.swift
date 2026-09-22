import CoreLocation
import Foundation
import MapKit

struct TravelRoute: Sendable, Identifiable {
    let mode: TravelMode
    let name: String
    let travelTime: Duration
    let distance: Measurement<UnitLength>
    let coordinates: [CLLocationCoordinate2D]
    let steps: [RouteStep]
    let advisories: [String]
    let hasTolls: Bool

    var id: String { "\(mode.rawValue)|\(name)|\(steps.count)" }

    var timeLabel: String { travelTime.travelLabel }

    func arrival(departingAt departure: Date) -> Date {
        departure.addingTimeInterval(
            TimeInterval(travelTime.components.seconds)
        )
    }
}

struct RouteStep: Sendable, Identifiable {
    let position: Int
    let instructions: String
    let notice: String?
    let distance: Measurement<UnitLength>
    let isArrival: Bool

    var id: Int { position }

    var symbolName: String {
        isArrival
            ? "mappin.and.ellipse"
            : "arrow.triangle.turn.up.right.diamond"
    }
}

extension TravelRoute {
    init(_ route: MKRoute, mode: TravelMode) {
        let steps = route.steps.filter { !$0.instructions.isEmpty }
        self.init(
            mode: mode,
            name: route.name,
            travelTime: .seconds(route.expectedTravelTime),
            distance: Measurement(value: route.distance, unit: .meters),
            coordinates: route.polyline.coordinates,
            steps: steps.enumerated().map { position, step in
                RouteStep(
                    position: position,
                    instructions: step.instructions,
                    notice: step.notice,
                    distance: Measurement(value: step.distance, unit: .meters),
                    isArrival: position == steps.count - 1
                )
            },
            advisories: route.advisoryNotices,
            hasTolls: route.hasTolls
        )
    }
}

extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        let points = points()
        return (0..<pointCount).map { points[$0].coordinate }
    }
}

extension Collection<CLLocationCoordinate2D> {
    /// Map rect enclosing every coordinate, grown by `padding` on each side so a
    /// framed route is not flush against the edges of the map.
    func boundingRect(padding: Double = 0.2) -> MKMapRect? {
        let rect = reduce(MKMapRect.null) { rect, coordinate in
            rect.union(
                MKMapRect(
                    origin: MKMapPoint(coordinate),
                    size: MKMapSize(width: 0, height: 0)
                )
            )
        }
        guard !rect.isNull, rect.width > 0 || rect.height > 0 else {
            return nil
        }
        let inset = Swift.max(rect.width, rect.height) * padding
        return rect.insetBy(dx: -inset, dy: -inset)
    }
}
