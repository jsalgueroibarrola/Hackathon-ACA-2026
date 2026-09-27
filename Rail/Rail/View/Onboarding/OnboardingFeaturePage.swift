import SwiftUI

struct OnboardingFeaturePage<Artwork: View, Content: View>: View {
    enum Placement {
        case fullBleed
        case belowTopBar
    }

    private struct ScrollState: Equatable {
        var topInset: CGFloat = 0
        var isScrolled = false
    }

    private let placement: Placement
    private let artwork: Artwork
    private let content: Content
    private let actions: OnboardingActionBar

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var scroll = ScrollState()

    private static var minimumArtworkHeight: CGFloat { 160 }

    init(
        placement: Placement = .belowTopBar,
        actions: OnboardingActionBar,
        @ViewBuilder artwork: () -> Artwork,
        @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.actions = actions
        self.artwork = artwork()
        self.content = content()
    }

    var body: some View {
        if verticalSizeClass == .compact {
            sideBySide
        } else {
            stacked
        }
    }

    private var stacked: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(minHeight: Self.minimumArtworkHeight)
                    .background {
                        artwork
                            .padding(.top, placement == .fullBleed ? -scroll.topInset : 0)
                    }
                column
            }
            .fitsScrollViewport()
        }
        .scrollBounceBehavior(.basedOnSize)
        .onScrollGeometryChange(for: ScrollState.self) { geometry in
            ScrollState(
                topInset: geometry.contentInsets.top,
                isScrolled: geometry.contentOffset.y + geometry.contentInsets.top > 0
            )
        } action: { _, newValue in
            scroll = newValue
        }
        .scrollEdgeEffectHidden(!scroll.isScrolled, for: .top)
        .safeAreaBar(edge: .bottom) { actions }
    }

    private var sideBySide: some View {
        HStack(spacing: 0) {
            Color.clear
                .overlay { artwork }
                .clipped()
                .ignoresSafeArea()
            ScrollView {
                column
                    .frame(maxHeight: .infinity)
                    .fitsScrollViewport()
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaBar(edge: .bottom) { actions }
        }
    }

    private var column: some View {
        content
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            .onboardingColumn()
    }
}
