import SwiftUI

struct LineTint: Sendable {
    let base: Color

    var text: Color { .white }

    var subtle: Color {
        let light = UIColor(base.mix(with: .white, by: 0.92))
        let dark = UIColor(base.mix(with: .black, by: 0.55))
        return Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

extension Line {
    var tint: LineTint {
        LineTint(base: Color(hex: colorHex))
    }
}
