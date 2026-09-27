import Foundation

enum NearbyCarouselNotice: Hashable, Sendable {
    case permissionNeeded
    case permissionDenied
    case locating
    case locationUnavailable
    case farFromNetwork
}

enum NearbyCarouselAction: Hashable, Sendable {
    case requestLocation
    case openSettings
    case retryLocation
    case showNetwork
}

enum NearbyCarouselItem: Identifiable, Hashable, Sendable {
    case notice(NearbyCarouselNotice, lineID: String?)
    case station(NearbyStationItem)

    static let noticeID = "nearby-notice"

    var id: String {
        switch self {
        case .notice: Self.noticeID
        case .station(let item): item.id
        }
    }
}

struct NearbyStationItem: Identifiable, Hashable, Sendable {
    let row: StationRowItem
    let isAccessible: Bool

    var id: String { row.id }

    init(row: StationRowItem, isAccessible: Bool) {
        self.row = row
        self.isAccessible = isAccessible
    }

    init(_ station: Station, location: UserLocation?) {
        self.init(
            row: StationRowItemBuilder.item(for: station, location: location),
            isAccessible: station.isAccessible == true
        )
    }
}

struct NearbyFallback {
    let lineID: String
    let stations: [Station]
}

enum NearbyCarouselBuilder {
    static func items(
        authorization: LocationAuthorization,
        location: UserLocation?,
        hasLocationFailed: Bool,
        stations: [Station],
        fallback: NearbyFallback?,
        radius: Measurement<UnitLength> = NextTrainsCardStateBuilder.nearbyRadius
    ) -> [NearbyCarouselItem] {
        let notice: NearbyCarouselNotice? =
            switch (authorization, location) {
            case (.notDetermined, _): .permissionNeeded
            case (.denied, _), (.restricted, _): .permissionDenied
            case (.authorized, nil): hasLocationFailed ? .locationUnavailable : .locating
            case (.authorized, let location?):
                nearest(to: location, among: stations, radius: radius) == nil
                    ? .farFromNetwork : nil
            }
        return (notice.map { [.notice($0, lineID: fallback?.lineID)] } ?? [])
            + (fallback?.stations ?? []).map {
                .station(NearbyStationItem($0, location: location))
            }
    }

    static func nearest(
        to location: UserLocation?,
        among stations: [Station],
        radius: Measurement<UnitLength> = NextTrainsCardStateBuilder.nearbyRadius
    ) -> Station? {
        location
            .flatMap { NearbyStation.closest(to: $0, among: stations, limit: 1).first }
            .flatMap { $0.distance <= radius ? $0.station : nil }
    }
}

extension NearbyCarouselNotice {
    var action: NearbyCarouselAction? {
        switch self {
        case .permissionNeeded: .requestLocation
        case .permissionDenied: .openSettings
        case .locating: nil
        case .locationUnavailable: .retryLocation
        case .farFromNetwork: .showNetwork
        }
    }
}
