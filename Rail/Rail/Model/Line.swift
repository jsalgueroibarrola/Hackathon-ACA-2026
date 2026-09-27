import Foundation
import SwiftData

@Model
final class Line {
    #Unique<Line>([\.id])

    /// Identifier of the line, for example `C1`. Referenced by ``Trip/lineID``.
    var id: String
    /// Long display name of the line, usually `origin – destination`.
    var name: String
    /// Six digit hex RGB colour without a leading `#`. Text drawn on top of it is white.
    var colorHex: String
    /// Google encoded polyline with precision 5 covering the whole route, in direction `0` order.
    var shape: String

    var network: TransitNetwork?

    /// Calls of this line at stations. Stored unordered by SwiftData: read them through ``orderedStops``.
    @Relationship(deleteRule: .cascade, inverse: \LineStop.line)
    var stops: [LineStop]

    init(id: String, name: String, colorHex: String, shape: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.shape = shape
        self.stops = []
    }
}

extension Line {
    /// Sendable snapshot of the route geometry, safe to hand to ``RouteShapeCache``.
    var routeShape: RouteShape {
        RouteShape(lineID: id, encoded: shape)
    }

    var orderedStops: [LineStop] {
        stops.sorted { $0.sequence < $1.sequence }
    }

    func orderedStops(for direction: TripDirection) -> [LineStop] {
        switch direction {
        case .outbound: orderedStops
        case .inbound: orderedStops.reversed()
        }
    }
}

struct RouteShape: Sendable, Hashable {
    let lineID: String
    let encoded: String
}
