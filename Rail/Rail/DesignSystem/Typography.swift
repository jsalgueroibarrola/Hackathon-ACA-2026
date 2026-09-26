import SwiftUI

extension Font {
    static let title2Emphasized: Font = .title2.weight(.bold)
    static let title3Emphasized: Font = .title3.weight(.semibold)
    static let bodyEmphasized: Font = .body.weight(.semibold)
    static let bodyMedium: Font = .body.weight(.medium)
    static let subheadlineEmphasized: Font = .subheadline.weight(.semibold)
    static let captionEmphasized: Font = .caption.weight(.semibold)
    static let timeDeparture: Font = .body.weight(.semibold).monospacedDigit()
    static let timeDepartureLarge: Font = .title2.weight(.bold).monospacedDigit()
}

enum Tracking {
    static let wide: CGFloat = 0.6
}
