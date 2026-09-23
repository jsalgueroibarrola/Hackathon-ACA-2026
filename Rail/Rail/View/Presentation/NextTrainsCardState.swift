import Foundation

enum NextTrainsCardState: Hashable, Sendable {
    case locating
    case permissionNeeded
    case permissionDenied
    case locationUnavailable
    case noStationNearby(name: String, distance: String)
    case station(NextTrainsStation)
}

struct NextTrainsStation: Hashable, Sendable {
    let name: String
    let proximity: NextTrainsProximity
    let departures: NextTrainsDepartures
}

enum NextTrainsProximity: Hashable, Sendable {
    case walking(minutes: Int)
    case distance(String)
    case saved
}

enum NextTrainsDepartures: Hashable, Sendable {
    case loading
    case upcoming([NextTrainsDeparture])
    case finished(firstTomorrow: String?)
}

struct NextTrainsDeparture: Identifiable, Hashable, Sendable {
    let id: String
    let line: String
    let colorHex: String
    let destination: String
    let time: String
}

enum NextTrainsCardAction: Hashable, Sendable {
    case requestLocation
    case openSettings
    case retryLocation
    case chooseStation
    case showMap
}
