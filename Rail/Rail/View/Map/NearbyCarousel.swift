import SwiftUI

struct NearbyCarousel: View {
    let items: [NearbyCarouselItem]
    let liveTrains: [String: NearbyLiveTrain]
    @Binding var focusedID: String?
    let isHidden: Bool
    let onOpen: (String) -> Void
    let onBrowse: (String) -> Void
    let onAction: (NearbyCarouselAction) -> Void

    @Environment(\.hiddenCarouselCardID) private var hiddenCardID
    @State private var isPulling = false
    @State private var isSwiping = false

    var body: some View {
        ScrollView(.vertical) {
            cards
        }
        .scrollBounceBehavior(.always, axes: .vertical)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .fixedSize(horizontal: false, vertical: true)
        .onScrollPhaseChange { _, phase in
            isPulling = phase == .interacting
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, pull in
            guard isPulling, pull > Self.openPull, !isHidden, let focusedStationID else { return }
            isPulling = false
            onOpen(focusedStationID)
        }
    }

    private var focusedStationID: String? {
        items.lazy.compactMap { item -> String? in
            guard case .station(let station) = item, station.id == focusedID else { return nil }
            return station.id
        }
        .first
    }

    private var cards: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: Spacing.sm) {
                ForEach(items) { item in
                    card(for: item)
                        .containerRelativeFrame(.horizontal) { length, _ in
                            min(length * Self.cardWidthRatio, Self.maxCardWidth)
                        }
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : Self.restingScale)
                                .opacity(phase.isIdentity ? 1 : Self.restingOpacity)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, ScreenLayout.margin, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $focusedID, anchor: .center)
        .onScrollPhaseChange { _, phase in
            isSwiping = phase.isScrolling
        }
        .onChange(of: focusedID) { _, focusedID in
            guard isSwiping, let focusedID else { return }
            onBrowse(focusedID)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .fixedSize(horizontal: false, vertical: true)
        .sensoryFeedback(.selection, trigger: focusedID) { previous, current in
            previous != nil && current != nil && !isHidden
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(Self.title))
    }

    @ViewBuilder
    private func card(for item: NearbyCarouselItem) -> some View {
        switch item {
        case .notice(let notice, let lineID):
            NearbyNoticeCard(notice, lineID: lineID, onAction: onAction)
        case .station(let station):
            NearbyStationCard(station, liveTrains: liveTrains)
                .opacity(station.id == hiddenCardID ? 0 : 1)
                .onTapGesture {
                    onOpen(station.id)
                }
                .accessibilityAction {
                    onOpen(station.id)
                }
        }
    }

    private static let openPull: CGFloat = 24
    private static let cardWidthRatio: CGFloat = 0.88
    private static let maxCardWidth: CGFloat = 360
    private nonisolated static let restingScale: CGFloat = 0.94
    private nonisolated static let restingOpacity: Double = 0.75

    private static let title = LocalizedStringResource(
        "Estaciones cercanas",
        comment: "Mapa: etiqueta de VoiceOver del carrusel con las estaciones más cercanas al usuario."
    )
}
