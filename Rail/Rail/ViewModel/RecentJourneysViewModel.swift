import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class RecentJourneysViewModel {
    private let repository: any UserStationsRepository

    init(repository: any UserStationsRepository) {
        self.repository = repository
    }

    func record(originID: String, destinationID: String) {
        attempt {
            try repository.recordJourney(originID: originID, destinationID: destinationID)
        }
    }

    func remove(originID: String, destinationID: String) {
        attempt {
            try repository.removeRecentJourney(originID: originID, destinationID: destinationID)
        }
    }

    func clear() {
        attempt { try repository.clearRecentJourneys() }
    }

    private func attempt(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            Logger.userStations.error(
                "Recent journeys update failed: \(String(describing: error), privacy: .public)"
            )
        }
    }
}

#if DEBUG
extension RecentJourneysViewModel {
    static func preview(
        repository: any UserStationsRepository = PreviewUserStationsRepository()
    ) -> RecentJourneysViewModel {
        RecentJourneysViewModel(repository: repository)
    }
}
#endif
