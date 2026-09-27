import Foundation

enum OnboardingStationsBuilder {
    static let suggestionLimit = 5

    static func items(
        lines: [Line],
        favoriteIDs: Set<String>,
        location: UserLocation?
    ) -> [StationRowItem] {
        let network = networkOrder(lines)
        let nearby = location.flatMap { nearbyLocation($0, among: network) }
        let ranked = sorted(network, from: nearby)
        let suggested = ranked.prefix(suggestionLimit)
        let suggestedIDs = Set(suggested.map(\.id))
        let favorites = ranked.filter {
            favoriteIDs.contains($0.id) && !suggestedIDs.contains($0.id)
        }
        return (Array(suggested) + favorites)
            .map { StationRowItemBuilder.item(for: $0, location: nearby) }
    }

    static func networkOrder(_ lines: [Line]) -> [Station] {
        lines.sortedByID
            .flatMap { $0.orderedStops.compactMap(\.station) }
            .reduce(into: (seen: Set<String>(), stations: [Station]())) { result, station in
                if result.seen.insert(station.id).inserted {
                    result.stations.append(station)
                }
            }
            .stations
    }

    private static func nearbyLocation(
        _ location: UserLocation,
        among stations: [Station]
    ) -> UserLocation? {
        NearbyStation.closest(to: location, among: stations, limit: 1)
            .first
            .flatMap { $0.distance <= NextTrainsCardStateBuilder.nearbyRadius ? location : nil }
    }

    private static func sorted(_ stations: [Station], from location: UserLocation?) -> [Station] {
        location.map { location in
            NearbyStation.closest(to: location, among: stations, limit: stations.count)
                .map(\.station)
        } ?? stations
    }
}
