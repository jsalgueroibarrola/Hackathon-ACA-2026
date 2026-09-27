import SwiftUI

struct LineTint: Sendable {
    let base: Color

    var text: Color { .white }
}

extension Line {
    var tint: LineTint {
        LineTint(base: Color(hex: colorHex))
    }
}
