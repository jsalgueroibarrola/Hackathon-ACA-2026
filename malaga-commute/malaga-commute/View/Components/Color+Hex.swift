//
//  Color+Hex.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI

extension Color {
    /// Builds a colour from the six digit hex RGB string used by ``Line/colorHex``.
    /// Falls back to grey when the payload sends something unparseable.
    init(hex: String) {
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else {
            self = .gray
            return
        }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
