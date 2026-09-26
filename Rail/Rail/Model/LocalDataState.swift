import Foundation

struct LocalDataState: Sendable, Equatable {
    var networkID: String?
    var timeZoneIdentifier: String?
    var networkETag: String?
    var timetableETag: String?
    var startDay: Date?
    var endDay: Date?
    var lastFetchedAt: Date?
}

extension LocalDataState {
    var hasNetwork: Bool {
        networkID != nil
    }

    var timeZone: TimeZone {
        TimeZone(networkIdentifier: timeZoneIdentifier)
    }

    var calendar: Calendar {
        .network(in: timeZone)
    }
}
