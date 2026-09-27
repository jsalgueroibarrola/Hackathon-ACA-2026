import CoreGraphics

enum MapSheetOrigin: Hashable, Sendable {
    case card(String)
    case bottom

    var cardID: String? {
        guard case .card(let id) = self else { return nil }
        return id
    }
}

struct MapSheetMeasurements: Equatable, Sendable {
    var container: CGSize = .zero
    var topInset: CGFloat = 0
    var cardHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var contentHeight: CGFloat = 0
    var controlsSize: CGSize = .zero
}

struct MapSheetMetrics: Equatable, Sendable {
    let container: CGSize
    let topInset: CGFloat
    let baseline: CGFloat
    let height: CGFloat
    let sheetWidth: CGFloat
    let sheetMinX: CGFloat
    let cardHeight: CGFloat
    let controlsSize: CGSize
    let bodyOverflows: Bool

    var sheetRect: CGRect {
        CGRect(x: sheetMinX, y: baseline - height, width: sheetWidth, height: height)
    }
}

enum MapSheetLayout {
    static let baselineGap = Spacing.sm
    static let maxHeightFraction = 0.6
    static let minimumGap = Spacing.xxxxl
    static let closeFraction = 0.25
    static let rubberBandCoefficient = 0.55

    static func metrics(_ measurements: MapSheetMeasurements, isRegularWidth: Bool) -> MapSheetMetrics {
        let size = measurements.container
        let natural =
            measurements.contentHeight > 0
            ? measurements.headerHeight + measurements.contentHeight : .infinity
        let floor = measurements.cardHeight + minimumGap
        let height = clamp(natural, floor, max(floor, size.height * maxHeightFraction))
        let width = max(0, min(size.width - 2 * ScreenLayout.margin, ScreenLayout.maxContentWidth))
        return MapSheetMetrics(
            container: size,
            topInset: measurements.topInset,
            baseline: size.height - baselineGap,
            height: height,
            sheetWidth: width,
            sheetMinX: isRegularWidth ? ScreenLayout.margin : (size.width - width) / 2,
            cardHeight: measurements.cardHeight,
            controlsSize: measurements.controlsSize,
            bodyOverflows: natural > height + 0.5
        )
    }

    static func extent(forTop top: CGFloat, collapsedTop: CGFloat, metrics: MapSheetMetrics) -> CGFloat {
        let span = metrics.height - collapsedTop
        guard span > 0 else { return top < collapsedTop ? 0 : metrics.height }
        return clamp((top - collapsedTop) / span, 0, 1) * metrics.height
    }

    static func draggedTop(translation: CGFloat, floor: CGFloat, metrics: MapSheetMetrics) -> CGFloat {
        let top = min(metrics.height - translation, metrics.height)
        guard top < floor else { return top }
        return floor - rubberBand(floor - top, dimension: max(metrics.container.height, 1))
    }

    static func rubberBand(_ overflow: CGFloat, dimension: CGFloat) -> CGFloat {
        (1 - 1 / (overflow * rubberBandCoefficient / dimension + 1)) * dimension
    }

    static func shouldClose(projectedTranslation: CGFloat, metrics: MapSheetMetrics) -> Bool {
        projectedTranslation > metrics.height * closeFraction
    }

    static func openProgress(extent: CGFloat, metrics: MapSheetMetrics) -> Double {
        metrics.height > 0 ? clamp(extent / metrics.height, 0, 1) : 0
    }

    static func sheetFrame(extent: CGFloat, card: CGRect?, metrics: MapSheetMetrics) -> CGRect {
        guard extent < metrics.height else { return metrics.sheetRect }
        let progress = openProgress(extent: extent, metrics: metrics)
        return card.map { interpolate($0, metrics.sheetRect, progress) }
            ?? metrics.sheetRect.offsetBy(dx: 0, dy: metrics.height - extent)
    }

    static func interpolate(_ from: CGRect, _ to: CGRect, _ progress: Double) -> CGRect {
        CGRect(
            x: from.minX + (to.minX - from.minX) * progress,
            y: from.minY + (to.minY - from.minY) * progress,
            width: from.width + (to.width - from.width) * progress,
            height: from.height + (to.height - from.height) * progress
        )
    }

    static func clamp(_ value: CGFloat, _ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }
}
