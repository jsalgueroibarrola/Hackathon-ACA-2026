import Foundation
import SwiftData

@Model
final class Station {
    #Unique<Station>([\.id])
    #Index<Station>([\.name])

    /// Station code.
    var id: String
    /// Display name of the station.
    var name: String
    /// WGS84 latitude of the station.
    var latitude: Double
    /// WGS84 longitude of the station.
    var longitude: Double
    /// `true` when the station is accessible for reduced mobility, `nil` when unknown. Never `false`.
    var isAccessible: Bool?
    /// `true` when the station has an elevator, `nil` when unknown. Never `false`.
    var hasElevator: Bool?
    /// Connections with other means of transport. Empty when none are known.
    var connections: [StationConnection]

    var network: TransitNetwork?

    /// Calls of lines at this station, one per line the station belongs to.
    @Relationship(deleteRule: .cascade, inverse: \LineStop.station)
    var stops: [LineStop]

    init(
        id: String,
        name: String,
        latitude: Double,
        longitude: Double,
        isAccessible: Bool? = nil,
        hasElevator: Bool? = nil,
        connections: [StationConnection] = []
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isAccessible = isAccessible
        self.hasElevator = hasElevator
        self.connections = connections
        self.stops = []
    }
}

extension Station {
    var lines: [Line] {
        stops.compactMap(\.line)
    }
}

enum StationConnection: String, Codable, CaseIterable, Sendable {
    case airport
    case ave
    case busStation
    case interurbanBus
    case metro
    case regional
    case urbanBus
}
