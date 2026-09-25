import Foundation

enum NextTrainsWidgetSnapshot: Hashable, Sendable {
    case unavailable
    case unknownStation
    case station(NextTrainsWidgetStation)
}

struct NextTrainsWidgetStation: Hashable, Sendable {
    let id: String
    let name: String
    let timeZone: TimeZone
    let today: [NextTrainsWidgetRow]
    let firstTomorrow: Date?
}
