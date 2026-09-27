import Foundation

enum MapFeedStatus: Equatable {
    case loading
    case offline

    static let offlineTrainLifetime: TimeInterval = 60

    static func resolve(isOnline: Bool, hasLoadedTrains: Bool) -> MapFeedStatus? {
        switch (isOnline, hasLoadedTrains) {
        case (false, _): .offline
        case (true, false): .loading
        case (true, true): nil
        }
    }

    static func trainsHiddenAfter(isOnline: Bool, fetchedAt: Date?) -> Date? {
        guard !isOnline else { return nil }
        return fetchedAt.map { $0.addingTimeInterval(offlineTrainLifetime) } ?? .distantPast
    }
}
