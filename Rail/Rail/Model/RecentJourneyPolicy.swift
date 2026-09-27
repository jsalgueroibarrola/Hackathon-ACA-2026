import Foundation

extension RecentJourney {
    static var order: [SortDescriptor<RecentJourney>] {
        [SortDescriptor(\.lastSearchedAt, order: .reverse)]
    }
}

enum RecentJourneyPolicy {
    static let limit = 15
    static let maxAge: TimeInterval = 30 * 86_400

    static func isExpired(_ lastSearchedAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(lastSearchedAt) > maxAge
    }

    static func discarded<Item>(
        _ items: [Item],
        lastSearchedAt: (Item) -> Date,
        now: Date
    ) -> [Item] {
        items
            .sorted { lastSearchedAt($0) > lastSearchedAt($1) }
            .enumerated()
            .filter { offset, item in
                offset >= limit || isExpired(lastSearchedAt(item), now: now)
            }
            .map(\.element)
    }
}
