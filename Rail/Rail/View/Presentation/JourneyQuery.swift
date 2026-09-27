import Foundation

struct JourneyQuery: Hashable, Sendable {
    let originID: String
    let destinationID: String
    let day: Date?
}

extension JourneyQuery {
    var reversed: JourneyQuery {
        JourneyQuery(originID: destinationID, destinationID: originID, day: day)
    }

    func on(_ day: Date?) -> JourneyQuery {
        JourneyQuery(originID: originID, destinationID: destinationID, day: day)
    }
}

struct RecentJourneyItem: Identifiable, Hashable, Sendable {
    let originID: String
    let destinationID: String
    let originName: String
    let destinationName: String
    let lastSearchedAt: Date

    var id: String { "\(originID)-\(destinationID)" }

    var query: JourneyQuery {
        JourneyQuery(originID: originID, destinationID: destinationID, day: nil)
    }
}

enum RecentJourneyItemBuilder {
    static func items(
        _ recents: [RecentJourney],
        stationNames: [String: String],
        now: Date
    ) -> [RecentJourneyItem] {
        Array(
            recents
                .filter { !RecentJourneyPolicy.isExpired($0.lastSearchedAt, now: now) }
                .sorted { $0.lastSearchedAt > $1.lastSearchedAt }
                .compactMap { recent in
                    guard let origin = stationNames[recent.originID],
                          let destination = stationNames[recent.destinationID]
                    else { return nil }
                    return RecentJourneyItem(
                        originID: recent.originID,
                        destinationID: recent.destinationID,
                        originName: origin,
                        destinationName: destination,
                        lastSearchedAt: recent.lastSearchedAt
                    )
                }
                .prefix(RecentJourneyPolicy.limit)
        )
    }
}
