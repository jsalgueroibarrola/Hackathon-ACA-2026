import Foundation
import SwiftData

@ModelActor
actor SwiftDataLiveFeedRepository: LiveFeedRepository {

    func state(of feed: LiveFeed) async throws -> LiveFeedState {
        switch feed {
        case .alerts:
            try modelContext.first(ServiceAlertFeed.self)
                .map { LiveFeedState(etag: $0.etag, expiresAt: $0.expiresAt) }
                ?? .empty
        case .realtime:
            try modelContext.first(RealtimeFeed.self)
                .map { LiveFeedState(etag: $0.etag, expiresAt: $0.expiresAt) }
                ?? .empty
        }
    }

    func replaceAlerts(
        _ response: ETagged<AlertsResponseDTO>,
        fetchedAt: Date
    ) async throws {
        try modelContext.commit {
            try modelContext.deleteAll(ServiceAlert.self)
            try modelContext.deleteAll(ServiceAlertFeed.self)

            let feed = ServiceAlertFeed(
                dto: response.value,
                etag: response.etag,
                freshness: response.freshness,
                fetchedAt: fetchedAt,
                fallbackInterval: LiveFeed.alerts.fallbackInterval
            )
            modelContext.insert(feed)

            let alerts = response.value.alerts.enumerated().map { position, dto in
                ServiceAlert(dto: dto, position: position)
            }
            alerts.forEach { $0.feed = feed }
            modelContext.insertAll(alerts)
        }
    }

    func mergeRealtime(
        _ response: ETagged<RealtimeResponseDTO>,
        fetchedAt: Date
    ) async throws {
        guard let network = try modelContext.first(TransitNetwork.self) else {
            throw TransitRepositoryError.missingNetwork
        }
        let calendar = network.calendar
        let directions = try scheduledDirections(for: response.value.trains)
        let previous = try modelContext.fetch(FetchDescriptor<LiveTrain>()).map(\.record)
        let incoming = response.value.trains.map {
            LiveTrainRecord(
                dto: $0,
                calendar: calendar,
                direction: directions["\($0.line)-\($0.train)"]
            )
        }
        let merged = RealtimeMerge.merge(
            previous: previous,
            incoming: incoming,
            now: fetchedAt
        )

        try modelContext.commit {
            try modelContext.deleteAll(LiveTrain.self)
            try modelContext.deleteAll(RealtimeFeed.self)

            let feed = RealtimeFeed(
                dto: response.value,
                etag: response.etag,
                freshness: response.freshness,
                fetchedAt: fetchedAt,
                fallbackInterval: LiveFeed.realtime.fallbackInterval
            )
            modelContext.insert(feed)

            let trains = merged.map(LiveTrain.init(record:))
            trains.forEach { $0.feed = feed }
            modelContext.insertAll(trains)
        }
    }

    private func scheduledDirections(
        for trains: [LiveTrainDTO]
    ) throws -> [String: TripDirection] {
        let numbers = Array(Set(trains.map(\.train)))
        let trips = try modelContext.fetch(
            FetchDescriptor<Trip>(predicate: #Predicate { numbers.contains($0.train) })
        )
        return Dictionary(
            trips.map { ("\($0.lineID)-\($0.train)", $0.direction) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func markRevalidated(
        _ feed: LiveFeed,
        freshness: CacheFreshness,
        at date: Date
    ) async throws {
        let expiresAt = freshness.expiry(from: date, fallback: feed.fallbackInterval)

        try modelContext.commit {
            switch feed {
            case .alerts:
                if let stored = try modelContext.first(ServiceAlertFeed.self) {
                    stored.fetchedAt = date
                    stored.expiresAt = expiresAt
                    stored.isStale = freshness.isStale
                }
            case .realtime:
                if let stored = try modelContext.first(RealtimeFeed.self) {
                    stored.fetchedAt = date
                    stored.expiresAt = expiresAt
                    stored.isStale = freshness.isStale
                }
            }
        }
    }
}
