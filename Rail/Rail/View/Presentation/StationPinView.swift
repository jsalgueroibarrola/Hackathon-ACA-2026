import MapKit
import SwiftUI

struct StationPin: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let isAccessible: Bool
    let hasElevator: Bool
    let connections: [StationConnection]
    let lineIDs: [String]
    let colorHexes: [String]

    init(
        id: String,
        name: String,
        latitude: Double,
        longitude: Double,
        isAccessible: Bool = false,
        hasElevator: Bool = false,
        connections: [StationConnection] = [],
        lineIDs: [String] = [],
        colorHexes: [String] = []
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isAccessible = isAccessible
        self.hasElevator = hasElevator
        self.connections = connections
        self.lineIDs = lineIDs
        self.colorHexes = colorHexes
    }

    init(station: Station) {
        let lines = station.lines.sorted { $0.id < $1.id }
        self.id = station.id
        self.name = station.name
        self.latitude = station.latitude
        self.longitude = station.longitude
        self.isAccessible = station.isAccessible == true
        self.hasElevator = station.hasElevator == true
        self.connections = station.connections
        self.lineIDs = lines.map(\.id)
        self.colorHexes = lines.map(\.colorHex)
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let interchangeColor = Color.textPrimary
    static let accessibleTint = Color.statusInfo
    static let elevatorTint = Color.interactiveIconSubtle

    var color: Color {
        switch (isInterchange, colorHexes.first) {
        case (true, _): Self.interchangeColor
        case (false, let hex?): Color(hex: hex)
        case (false, nil): .interactiveIconSubtle
        }
    }

    var isInterchange: Bool { lineIDs.count > 1 }
}

enum ZoomBucket: Comparable, CaseIterable {
    case overview
    case region
    case street
    case detail

    init(distance: CLLocationDistance) {
        switch distance {
        case ..<3_000: self = .detail
        case ..<9_000: self = .street
        case ..<45_000: self = .region
        default: self = .overview
        }
    }

    var dotSize: CGFloat {
        switch self {
        case .overview: 9
        case .region: 13
        case .street: 17
        case .detail: 20
        }
    }

    var lowerBound: CLLocationDistance {
        switch self {
        case .overview: 45_000
        case .region: 9_000
        case .street: 3_000
        case .detail: 0
        }
    }

    var upperBound: CLLocationDistance {
        switch self {
        case .overview: .infinity
        case .region: 45_000
        case .street: 9_000
        case .detail: 3_000
        }
    }

    func updated(
        for distance: CLLocationDistance,
        margin: Double = 0.12
    ) -> ZoomBucket {
        switch distance {
        case lowerBound * (1 - margin)...upperBound * (1 + margin): self
        default: ZoomBucket(distance: distance)
        }
    }

    var showsAccessibility: Bool { self >= .region }
    var showsChip: Bool { self >= .street }
    var showsConnections: Bool { self == .detail }
}
