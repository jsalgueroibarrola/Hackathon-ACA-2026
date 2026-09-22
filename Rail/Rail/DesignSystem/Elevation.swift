import SwiftUI

enum Elevation {
    case none
    case card
    case sheet
    case floating
}

private struct ElevationModifier: ViewModifier {
    let level: Elevation

    @ViewBuilder
    func body(content: Content) -> some View {
        switch level {
        case .none:
            content
        case .card:
            content
                .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
        case .sheet:
            content
                .shadow(color: .black.opacity(0.12), radius: 6, y: -2)
        case .floating:
            content
                .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
                .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
        }
    }
}

extension View {
    func elevation(_ level: Elevation) -> some View {
        modifier(ElevationModifier(level: level))
    }
}
