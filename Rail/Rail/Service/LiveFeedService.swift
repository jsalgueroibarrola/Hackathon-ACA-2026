import Foundation
import OSLog

enum LiveFeed: Sendable, Hashable, CaseIterable {
    case alerts
    case realtime

    var fallbackInterval: Duration {
        switch self {
        case .alerts: .seconds(60)
        case .realtime: .seconds(20)
        }
    }
}

enum LiveFeedOutcome: Sendable, Equatable {
    case updated
    case unchanged
    case skipped
    case failed
}

struct LiveFeedRefresh: Sendable, Equatable {
    let outcome: LiveFeedOutcome
    let nextDelay: Duration
}

protocol LiveFeedService: Sendable {
    func refresh(_ feed: LiveFeed, now: Date, force: Bool) async -> LiveFeedRefresh
}

extension LiveFeedService {
    func refresh(_ feed: LiveFeed, now: Date = .now) async -> LiveFeedRefresh {
        await refresh(feed, now: now, force: false)
    }

    func poll(
        _ feed: LiveFeed,
        onRefresh: (LiveFeedRefresh) -> Void = { _ in }
    ) async {
        while !Task.isCancelled {
            let refresh = await refresh(feed)
            onRefresh(refresh)
            do {
                try await Task.sleep(for: refresh.nextDelay)
            } catch {
                return
            }
        }
    }
}

struct LiveFeedServiceImpl: LiveFeedService {

    let api: any APIService
    let repository: any LiveFeedRepository
    var schedule: PollSchedule = .standard

    func refresh(_ feed: LiveFeed, now: Date, force: Bool) async -> LiveFeedRefresh {
        do {
            let state = try await repository.state(of: feed)

            if !force, let expiresAt = state.expiresAt, expiresAt > now {
                return LiveFeedRefresh(
                    outcome: .skipped,
                    nextDelay: schedule.delay(
                        freshFor: .seconds(expiresAt.timeIntervalSince(now)),
                        fallback: feed.fallbackInterval
                    )
                )
            }

            let (outcome, freshness) = try await download(feed, etag: state.etag, now: now)
            return LiveFeedRefresh(
                outcome: outcome,
                nextDelay: schedule.delay(
                    freshFor: freshness.freshFor,
                    fallback: feed.fallbackInterval
                )
            )
        } catch NetworkError.serviceUnavailable(let retryAfter) {
            Logger.liveFeeds.notice("\(String(describing: feed)) unavailable, retrying later")
            return LiveFeedRefresh(
                outcome: .failed,
                nextDelay: schedule.delay(retryAfter: retryAfter, fallback: feed.fallbackInterval)
            )
        } catch NetworkError.cancelled {
            return LiveFeedRefresh(outcome: .failed, nextDelay: feed.fallbackInterval)
        } catch is CancellationError {
            return LiveFeedRefresh(outcome: .failed, nextDelay: feed.fallbackInterval)
        } catch {
            Logger.liveFeeds.error("\(String(describing: feed)) refresh failed: \(error.localizedDescription)")
            return LiveFeedRefresh(
                outcome: .failed,
                nextDelay: schedule.delay(retryAfter: nil, fallback: feed.fallbackInterval)
            )
        }
    }

    private func download(
        _ feed: LiveFeed,
        etag: String?,
        now: Date
    ) async throws -> (LiveFeedOutcome, CacheFreshness) {
        switch feed {
        case .alerts:
            try await store(await api.getAlerts(etag: etag), feed: feed, now: now) {
                try await repository.replaceAlerts($0, fetchedAt: now)
            }
        case .realtime:
            try await store(await api.getRealtime(etag: etag), feed: feed, now: now) {
                try await repository.replaceRealtime($0, fetchedAt: now)
            }
        }
    }

    private func store<Payload: Sendable>(
        _ response: APIResponse<ETagged<Payload>>,
        feed: LiveFeed,
        now: Date,
        replace: (ETagged<Payload>) async throws -> Void
    ) async throws -> (LiveFeedOutcome, CacheFreshness) {
        switch response {
        case .success(let payload):
            try await replace(payload)
            return (.updated, payload.freshness)
        case .notModified(let freshness):
            try await repository.markRevalidated(feed, freshness: freshness, at: now)
            return (.unchanged, freshness)
        case .failure(let error):
            throw error
        }
    }
}

struct DisabledLiveFeedService: LiveFeedService {
    func refresh(_ feed: LiveFeed, now: Date, force: Bool) async -> LiveFeedRefresh {
        LiveFeedRefresh(outcome: .skipped, nextDelay: feed.fallbackInterval)
    }
}
