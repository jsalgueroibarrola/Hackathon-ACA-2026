import CoreGraphics

enum VerticalDragEvent: Equatable, Sendable {
    case changed(CGFloat)
    case ended(translation: CGFloat, predicted: CGFloat)
    case cancelled
}

enum VerticalDragResolver {
    static func accepts(_ translation: CGSize) -> Bool {
        abs(translation.height) > abs(translation.width)
    }
}
