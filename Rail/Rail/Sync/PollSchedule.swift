import Foundation

struct PollSchedule: Sendable {
    var margin: Duration = .seconds(1)
    var expiredRetry: Duration = .seconds(10)
    var jitter: @Sendable () -> Duration = { .seconds(Double.random(in: 0...2)) }

    static let standard = PollSchedule()

    func delay(freshFor: Duration?, fallback: Duration) -> Duration {
        let base: Duration = switch freshFor {
        case .some(let remaining) where remaining > .zero: remaining + margin
        case .some: expiredRetry
        case .none: fallback
        }
        return base + jitter()
    }

    func delay(retryAfter: Duration?, fallback: Duration) -> Duration {
        retryAfter ?? fallback
    }
}
