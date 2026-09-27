import CoreGraphics

struct MapBottomChrome: Equatable, Sendable {
    let showsSheet: Bool
    let carouselOpacity: Double
    let sheetOpacity: Double
    let cardContentOpacity: Double
    let sheetContentOpacity: Double

    static let bottomFadeDistance: CGFloat = 48

    static func resolve(
        extent: CGFloat,
        presence: Double,
        hasCard: Bool,
        reduceMotion: Bool,
        metrics: MapSheetMetrics
    ) -> Self {
        let progress = reduceMotion ? presence : MapSheetLayout.openProgress(extent: extent, metrics: metrics)
        let morphs = hasCard && !reduceMotion
        return MapBottomChrome(
            showsSheet: reduceMotion ? presence > 0.001 : extent > 0.5,
            carouselOpacity: 1 - progress,
            sheetOpacity: reduceMotion
                ? presence : morphs ? 1 : MapSheetLayout.clamp(extent / bottomFadeDistance, 0, 1),
            cardContentOpacity: morphs ? 1 - smoothstep(0, 0.5, progress) : 0,
            sheetContentOpacity: morphs ? smoothstep(0.25, 0.75, progress) : 1
        )
    }

    static func smoothstep(_ lower: Double, _ upper: Double, _ value: Double) -> Double {
        let t = MapSheetLayout.clamp((value - lower) / (upper - lower), 0, 1)
        return t * t * (3 - 2 * t)
    }
}

struct MapControlsPlacement: Equatable, Sendable {
    let bottom: CGFloat
    let opacity: Double

    static let gap = Spacing.sm
    static let roomFadeDistance: CGFloat = 24

    static func resolve(
        sheetFrame: CGRect?,
        carouselHeight: CGFloat,
        presence: Double,
        reduceMotion: Bool,
        metrics: MapSheetMetrics
    ) -> Self {
        let size = metrics.container
        let controlsMinX = size.width - ScreenLayout.margin - metrics.controlsSize.width
        let countsSheet = !reduceMotion || presence >= 0.5
        let sheetTop =
            sheetFrame
            .filter { countsSheet && $0.maxX > controlsMinX }
            .map { size.height - $0.minY } ?? 0
        let carouselTop = carouselHeight > 0 ? MapSheetLayout.baselineGap + carouselHeight : 0
        let openTop = MapSheetLayout.baselineGap + metrics.height
        let bottom = min(max(sheetTop, carouselTop), openTop) + gap
        let room = size.height - metrics.topInset - bottom - metrics.controlsSize.height - gap
        let roomFade = MapSheetLayout.clamp(room / roomFadeDistance, 0, 1)
        let crossfade = reduceMotion ? abs(2 * presence - 1) : 1
        return MapControlsPlacement(bottom: bottom, opacity: roomFade * crossfade)
    }
}

extension Optional {
    fileprivate func filter(_ isIncluded: (Wrapped) -> Bool) -> Wrapped? {
        flatMap { isIncluded($0) ? $0 : nil }
    }
}
