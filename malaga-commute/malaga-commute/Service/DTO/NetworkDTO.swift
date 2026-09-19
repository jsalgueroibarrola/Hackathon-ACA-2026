import Foundation

struct NetworkResponseDTO: Decodable, Sendable {
    /// Date the file was generated, as `YYYY-MM-DD`. Informative only: the real version of the payload is its `ETag`.
    let version: String
    /// Metadata describing the transit network as a whole.
    let network: NetworkInfoDTO
    /// Every line of the network, each one with its ordered stations and its map shape.
    let lines: [LineDTO]
    /// Every station of the network, sorted by `id`. The lines a station belongs to are derived from `lines[].stations`.
    let stations: [StationDTO]
}

struct NetworkInfoDTO: Decodable, Sendable {
    /// Identifier of the network, for example `malaga`.
    let id: String
    /// Display name of the network.
    let name: String
    /// IANA time zone every timetable is expressed in, for example `Europe/Madrid`. Always use this one, never the device time zone.
    let timezone: String
}

struct LineDTO: Decodable, Sendable {
    /// Identifier of the line, for example `C1`. Referenced by `TripDTO.line`.
    let id: String
    /// Long display name of the line, usually `origin – destination`.
    let name: String
    /// Six digit hex RGB colour without a leading `#`. Text drawn on top of it is white.
    let color: String
    /// Station ids in travel order for direction `0`. Direction `1` is this same list reversed. A station belongs to the line if it appears here.
    let stations: [String]
    /// Google encoded polyline with precision 5 covering the whole route, in the same order as `stations`.
    let shape: String
}

struct StationDTO: Decodable, Sendable {
    /// Station code. Stable across versions of the payload.
    let id: String
    /// Display name of the station.
    let name: String
    /// WGS84 latitude of the station.
    let lat: Double
    /// WGS84 longitude of the station.
    let lon: Double
    /// `true` when the station is accessible for reduced mobility. Absent means unknown, it is never `false`.
    let accessible: Bool?
    /// `true` when the station has an elevator. Absent means unknown, it is never `false`.
    let elevator: Bool?
    /// Connections with other means of transport. Absent means none known. Values that this app does not know about are discarded while decoding.
    let connections: [StationConnectionDTO]?

    private enum CodingKeys: String, CodingKey {
        case id, name, lat, lon, accessible, elevator, connections
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        accessible = try container.decodeIfPresent(Bool.self, forKey: .accessible)
        elevator = try container.decodeIfPresent(Bool.self, forKey: .elevator)
        connections = try container
            .decodeIfPresent([LenientStationConnectionDTO].self, forKey: .connections)?
            .compactMap(\.value)
    }
}

enum StationConnectionDTO: String, Decodable, Sendable {
    case airport
    case ave
    case busStation
    case interurbanBus
    case metro
    case regional
    case urbanBus
}

private struct LenientStationConnectionDTO: Decodable, Sendable {
    /// Decoded connection, or `nil` when the server sends a value added after this version of the app.
    let value: StationConnectionDTO?

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = StationConnectionDTO(rawValue: try container.decode(String.self))
    }
}
