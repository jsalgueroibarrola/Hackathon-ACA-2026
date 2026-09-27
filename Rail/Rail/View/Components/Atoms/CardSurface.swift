import SwiftUI

enum CardSurfaceStyle {
    case solid
    case translucent
}

extension EnvironmentValues {
    @Entry var cardSurfaceStyle: CardSurfaceStyle = .solid
}

extension View {
    func cardSurface(_ style: CardSurfaceStyle = .solid) -> some View {
        padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(style.fill, in: .rect(cornerRadius: Radius.md, style: .continuous))
            .environment(\.cardSurfaceStyle, style)
    }
}

extension CardSurfaceStyle {
    fileprivate var fill: AnyShapeStyle {
        switch self {
        case .solid: AnyShapeStyle(.bgPrimary)
        case .translucent: AnyShapeStyle(.thinMaterial)
        }
    }

    var sectionHeader: Color {
        switch self {
        case .solid: .textTertiary
        case .translucent: .textSecondary
        }
    }

    var separator: AnyShapeStyle {
        switch self {
        case .solid: AnyShapeStyle(.interactiveSeparator)
        case .translucent: AnyShapeStyle(.separator)
        }
    }
}
