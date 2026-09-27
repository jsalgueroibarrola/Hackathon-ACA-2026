import Foundation

struct LineTag: Identifiable, Hashable, Sendable {
    let id: String
    let colorHex: String
}

struct StationRowItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let subtitle: String?
    let distance: String?
    let lines: [LineTag]
}

enum StationRowItemBuilder {
    static func items(
        for stationIDs: [String],
        among stations: [Station],
        location: UserLocation?
    ) -> [StationRowItem] {
        let stationsByID = Dictionary(
            stations.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return stationIDs
            .compactMap { stationsByID[$0] }
            .map { item(for: $0, location: location) }
    }

    static func item(for station: Station, location: UserLocation?) -> StationRowItem {
        StationRowItem(
            id: station.id,
            name: station.name,
            subtitle: connectionsSummary(station.connections),
            distance: location.map { $0.distance(to: station.coordinate).distanceLabel },
            lines: Set(station.lines).sortedByID
                .map { LineTag(id: $0.id, colorHex: $0.colorHex) }
        )
    }

    private static func connectionsSummary(_ connections: [StationConnection]) -> String? {
        connections.isEmpty
            ? nil
            : connections.map { String(localized: $0.displayName) }.joined(separator: " · ")
    }
}
