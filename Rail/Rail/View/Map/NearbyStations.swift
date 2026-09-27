import SwiftData
import SwiftUI

struct NearbyStations: View {
    let stations: [Station]
    let fallback: NearbyFallback?
    let selectedID: String?
    @Binding var focusedID: String?
    let onOpen: (String) -> Void
    let onBrowse: (String) -> Void
    let onShowNetwork: () -> Void

    @Environment(LocationViewModel.self) private var location
    @Environment(\.openURL) private var openURL
    @Query private var liveTrains: [LiveTrain]
    @Query private var lines: [Line]
    @Query private var realtimeFeeds: [RealtimeFeed]

    private var carouselItems: [NearbyCarouselItem] {
        NearbyCarouselBuilder.items(
            authorization: location.authorization,
            location: location.location,
            hasLocationFailed: location.hasLocationFailed,
            stations: stations,
            fallback: fallback
        )
    }

    var body: some View {
        let items = carouselItems
        NearbyCarousel(
            items: items,
            liveTrains: NearbyDeparturesBuilder.liveTrains(
                from: liveTrains,
                lines: lines,
                fetchedAt: realtimeFeeds.first.map { $0.feedTimestamp ?? $0.fetchedAt }
            ),
            focusedID: $focusedID,
            isHidden: selectedID != nil,
            onOpen: onOpen,
            onBrowse: onBrowse,
            onAction: perform
        )
        .onChange(of: items.map(\.id), initial: true) { _, itemIDs in
            focusedID =
                itemIDs.contains { $0 == focusedID }
                ? focusedID
                : NearbyCarouselBuilder.nearest(to: location.location, among: stations)
                    .map(\.id)
                    .flatMap { itemIDs.contains($0) ? $0 : nil }
                    ?? itemIDs.first
        }
        .onChange(of: selectedID) { _, selectedID in
            guard let selectedID, items.contains(where: { $0.id == selectedID }) else { return }
            focusedID = selectedID
        }
    }

    private func perform(_ action: NearbyCarouselAction) {
        switch action {
        case .requestLocation:
            location.requestAccess()
        case .openSettings:
            if let settings = URL.appSettings {
                openURL(settings)
            }
        case .retryLocation:
            location.retry()
        case .showNetwork:
            onShowNetwork()
        }
    }
}
