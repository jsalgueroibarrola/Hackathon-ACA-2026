import SwiftUI

enum MapSheetMotion {
    static let tracking = Animation.interactiveSpring(duration: 0.15)
    static let contentSwap = Animation.smooth(duration: 0.25)
    static let camera = Animation.smooth(duration: 0.45)

    static func settle(reduceMotion: Bool) -> Animation {
        reduceMotion ? reducedMotion : .spring(duration: 0.4, bounce: 0)
    }

    static func dismiss(reduceMotion: Bool) -> Animation {
        reduceMotion ? reducedMotion : .spring(duration: 0.35, bounce: 0)
    }

    private static let reducedMotion = Animation.easeInOut(duration: 0.25)
}
