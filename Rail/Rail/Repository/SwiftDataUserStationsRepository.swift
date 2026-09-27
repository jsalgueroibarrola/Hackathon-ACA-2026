import Foundation
import SwiftData

@MainActor
final class SwiftDataUserStationsRepository: UserStationsRepository {

    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        modelContext = modelContainer.mainContext
    }

    func addFavorite(stationID: String) throws {
        try modelContext.commit {
            let favorites = try modelContext.fetch(
                FetchDescriptor<FavoriteStation>()
            )
            guard !favorites.contains(where: { $0.stationID == stationID })
            else { return }
            modelContext.insert(
                FavoriteStation(
                    stationID: stationID,
                    sortOrder: (favorites.map(\.sortOrder).max() ?? -1) + 1
                )
            )
        }
    }

    func removeFavorites(stationIDs: [String]) throws {
        try modelContext.commit {
            try modelContext.fetch(
                FetchDescriptor<FavoriteStation>(
                    predicate: #Predicate { stationIDs.contains($0.stationID) }
                )
            )
            .forEach { modelContext.delete($0) }
        }
    }

    func reorderFavorites(stationIDs: [String]) throws {
        let positions = Dictionary(
            stationIDs.enumerated().map { ($1, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        try modelContext.commit {
            try modelContext.fetch(
                FetchDescriptor<FavoriteStation>(sortBy: FavoriteStation.order)
            )
            .enumerated()
            .forEach { offset, favorite in
                favorite.sortOrder =
                    positions[favorite.stationID] ?? stationIDs.count + offset
            }
        }
    }

    func saveStation(_ location: SavedLocation) throws {
        try modelContext.commit {
            try modelContext.deleteAll(SavedStation.self)
            modelContext.insert(SavedStation(location))
        }
    }

    func clearSavedStation() throws {
        try modelContext.commit {
            try modelContext.deleteAll(SavedStation.self)
        }
    }

    func recordJourney(originID: String, destinationID: String) throws {
        let now = Date.now
        try modelContext.commit {
            let recents = try modelContext.fetch(FetchDescriptor<RecentJourney>())
            let existing = recents.first {
                $0.originID == originID && $0.destinationID == destinationID
            }
            let journey = existing ?? RecentJourney(
                originID: originID,
                destinationID: destinationID,
                lastSearchedAt: now
            )
            if existing == nil {
                modelContext.insert(journey)
            }
            journey.lastSearchedAt = now
            RecentJourneyPolicy.discarded(
                existing == nil ? recents + [journey] : recents,
                lastSearchedAt: \.lastSearchedAt,
                now: now
            )
            .forEach { modelContext.delete($0) }
        }
    }

    func removeRecentJourney(originID: String, destinationID: String) throws {
        try modelContext.commit {
            try modelContext.fetch(
                FetchDescriptor<RecentJourney>(
                    predicate: #Predicate {
                        $0.originID == originID && $0.destinationID == destinationID
                    }
                )
            )
            .forEach { modelContext.delete($0) }
        }
    }

    func clearRecentJourneys() throws {
        try modelContext.commit {
            try modelContext.deleteAll(RecentJourney.self)
        }
    }
}
