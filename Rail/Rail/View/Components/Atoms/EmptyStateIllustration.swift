import SwiftUI

struct EmptyStateIllustration: View {
    enum Kind: CaseIterable {
        case noFavorites
        case noResults
    }

    private let kind: Kind

    init(_ kind: Kind) {
        self.kind = kind
    }

    var body: some View {
        Image(kind.resource)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

extension EmptyStateIllustration.Kind {
    var resource: ImageResource {
        switch self {
        case .noFavorites: .posteFavoritos
        case .noResults: .senalSinResultados
        }
    }

    var height: CGFloat {
        switch self {
        case .noFavorites: 196
        case .noResults: 164
        }
    }
}

private struct EmptyStateIllustrationSamples: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xxl) {
            ForEach(EmptyStateIllustration.Kind.allCases, id: \.self) { kind in
                EmptyStateIllustration(kind)
                    .frame(height: kind.height)
            }
        }
        .padding(Spacing.xxl)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    EmptyStateIllustrationSamples()
}

#Preview("Modo oscuro") {
    EmptyStateIllustrationSamples()
        .preferredColorScheme(.dark)
}
