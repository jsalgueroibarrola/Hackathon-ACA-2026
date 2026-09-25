import Foundation

enum ServiceAlertsPhase: Equatable {
    case loading
    case unavailable
    case empty
    case content([ServiceAlertItem])
}

extension ServiceAlertsPhase {
    init(
        hasFeed: Bool,
        lastOutcome: LiveFeedOutcome?,
        items: [ServiceAlertItem]
    ) {
        self =
            switch (hasFeed, lastOutcome, items.isEmpty) {
            case (false, nil, _): .loading
            case (false, _?, _): .unavailable
            case (true, _, true): .empty
            case (true, _, false): .content(items)
            }
    }
}
