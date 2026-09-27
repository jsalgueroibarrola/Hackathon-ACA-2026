import SwiftUI

struct MapBottomCardAnchor: Equatable, Sendable {
    let bounds: Anchor<CGRect>
    let item: NearbyStationItem
    let departures: NearbyDepartures
}

struct MapBottomAnchors: PreferenceKey {
    static let defaultValue: [String: MapBottomCardAnchor] = [:]

    static func reduce(
        value: inout [String: MapBottomCardAnchor],
        nextValue: () -> [String: MapBottomCardAnchor]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

extension EnvironmentValues {
    @Entry var hiddenCarouselCardID: String?
}

struct MapBottomLayer<Carousel: View, Controls: View, Sheet: View>: View {
    let model: MapSheetModel
    let isPresented: Bool
    let carousel: Carousel
    let controls: Controls
    let sheet: Sheet?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let metrics = MapSheetLayout.metrics(
            model.measurements,
            isRegularWidth: horizontalSizeClass == .regular
        )
        MapBottomStage(
            extent: extent(metrics),
            presence: isPresented ? 1 : 0,
            metrics: metrics,
            sourceCardID: model.origin.cardID,
            isPresented: isPresented,
            reduceMotion: reduceMotion,
            carousel: carousel,
            controls: controls,
            sheet: sheet
        )
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            model.measure(\.container, size)
        }
    }

    private func extent(_ metrics: MapSheetMetrics) -> CGFloat {
        let collapsedTop = model.origin.cardID == nil ? 0 : metrics.cardHeight
        return switch (isPresented, model.dragTranslation) {
        case (true, .some(let translation)):
            MapSheetLayout.extent(
                forTop: MapSheetLayout.draggedTop(
                    translation: translation,
                    floor: collapsedTop,
                    metrics: metrics
                ),
                collapsedTop: collapsedTop,
                metrics: metrics
            )
        case (false, _) where !reduceMotion:
            0
        default:
            metrics.height
        }
    }
}

@Animatable
struct MapBottomStage<Carousel: View, Controls: View, Sheet: View>: View {
    var extent: CGFloat
    var presence: Double
    @AnimatableIgnored var metrics: MapSheetMetrics
    @AnimatableIgnored var sourceCardID: String?
    @AnimatableIgnored var isPresented: Bool
    @AnimatableIgnored var reduceMotion: Bool
    @AnimatableIgnored var carousel: Carousel
    @AnimatableIgnored var controls: Controls
    @AnimatableIgnored var sheet: Sheet?

    var body: some View {
        let base = chrome(hasCard: false)
        carousel
            .environment(\.hiddenCarouselCardID, base.showsSheet && !reduceMotion ? sourceCardID : nil)
            .padding(.bottom, MapSheetLayout.baselineGap)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .opacity(base.carouselOpacity)
            .allowsHitTesting(!isPresented)
            .accessibilityHidden(isPresented)
            .overlayPreferenceValue(MapBottomAnchors.self) { anchors in
                GeometryReader { proxy in
                    let card = reduceMotion ? nil : sourceCardID.flatMap { anchors[$0] }
                    let cardRect = card.map { proxy[$0.bounds] }
                    let chrome = chrome(hasCard: cardRect != nil)
                    let frame = MapSheetLayout.sheetFrame(extent: extent, card: cardRect, metrics: metrics)
                    let placement = MapControlsPlacement.resolve(
                        sheetFrame: chrome.showsSheet ? frame : nil,
                        carouselHeight: metrics.cardHeight,
                        presence: presence,
                        reduceMotion: reduceMotion,
                        metrics: metrics
                    )
                    ZStack(alignment: .topLeading) {
                        if chrome.showsSheet {
                            shell(frame: frame, cardRect: cardRect, card: card, chrome: chrome)
                        }
                        controls
                            .padding(.trailing, ScreenLayout.margin)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .offset(y: -placement.bottom)
                            .opacity(placement.opacity)
                            .allowsHitTesting(placement.opacity > 0.5)
                            .accessibilityHidden(placement.opacity < 0.5)
                    }
                }
            }
    }

    private func chrome(hasCard: Bool) -> MapBottomChrome {
        MapBottomChrome.resolve(
            extent: extent,
            presence: presence,
            hasCard: hasCard,
            reduceMotion: reduceMotion,
            metrics: metrics
        )
    }

    private func shell(
        frame: CGRect,
        cardRect: CGRect?,
        card: MapBottomCardAnchor?,
        chrome: MapBottomChrome
    ) -> some View {
        ZStack(alignment: .top) {
            if let card, let cardRect, chrome.cardContentOpacity > 0 {
                NearbyStationCardContent(card.item, departures: card.departures)
                    .frame(width: cardRect.width)
                    .opacity(chrome.cardContentOpacity)
                    .accessibilityHidden(true)
            }
            sheet
                .frame(
                    width: metrics.sheetWidth,
                    height: metrics.height,
                    alignment: .top
                )
                .opacity(chrome.sheetContentOpacity)
        }
        .frame(width: frame.width, height: frame.height, alignment: .top)
        .clipShape(.rect(cornerRadius: Radius.xl))
        .mapSheetSurface()
        .opacity(chrome.sheetOpacity)
        .offset(x: frame.minX, y: frame.minY)
        .accessibilityElement(children: .contain)
    }
}
