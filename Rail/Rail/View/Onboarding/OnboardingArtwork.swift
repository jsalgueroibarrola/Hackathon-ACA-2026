import SwiftUI

struct OnboardingArtwork: View {
    private let step: OnboardingStep

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private static let welcomeFocus = CGRect(x: 0.33, y: 0.055, width: 0.379, height: 0.679)
    private static let privacyMaxHeight: CGFloat = 520
    private static let locationAspectRatio: CGFloat = 1066 / 2198
    private static let locationVisibleFraction: CGFloat = 0.667
    private static let alertsAspectRatio: CGFloat = 2112 / 2304
    private static let alertsVisibleFraction: CGFloat = 0.92
    private static let croppedMaxHeight: CGFloat = 460

    init(_ step: OnboardingStep) {
        self.step = step
    }

    var body: some View {
        artwork
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var artwork: some View {
        switch step {
        case .welcome: welcome
        case .privacy: privacy
        case .location:
            croppedTop(
                .onboardingLocation,
                aspectRatio: Self.locationAspectRatio,
                visibleFraction: Self.locationVisibleFraction
            )
        case .alerts:
            croppedTop(
                .onboardingAlerts,
                aspectRatio: Self.alertsAspectRatio,
                visibleFraction: Self.alertsVisibleFraction
            )
        case .widgets: OnboardingWidgetShowcase()
        case .stations: EmptyView()
        }
    }

    private var welcome: some View {
        FocalFill(focus: Self.welcomeFocus) {
            Image(.onboardingWelcome)
                .resizable()
        }
        .clipped()
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0.6),
                    .init(color: .clear, location: 0.98),
                ],
                startPoint: verticalSizeClass == .compact ? .leading : .top,
                endPoint: verticalSizeClass == .compact ? .trailing : .bottom
            )
        }
    }

    private var privacy: some View {
        Image(.onboardingPrivacy)
            .resizable()
            .scaledToFit()
            .fixedSize(horizontal: true, vertical: false)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.065),
                        .init(color: .black, location: 0.36),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(maxHeight: Self.privacyMaxHeight)
            .padding(.top, -Spacing.xxxl)
            .padding(.bottom, Spacing.xxxl)
    }

    private func croppedTop(
        _ image: ImageResource,
        aspectRatio: CGFloat,
        visibleFraction: CGFloat
    ) -> some View {
        Color.clear
            .aspectRatio(aspectRatio / visibleFraction, contentMode: .fit)
            .frame(maxHeight: Self.croppedMaxHeight)
            .overlay(alignment: .top) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .clipped()
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0.555),
                        .init(color: .black.opacity(0.5), location: 0.823),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .padding(.top, OnboardingLayout.regularTopInset)
            .padding(.bottom, Spacing.sm)
    }
}

#if DEBUG
#Preview("Variantes Figma") {
    HStack(spacing: Spacing.lg) {
        ForEach(OnboardingStep.allCases.filter(\.hasArtwork), id: \.self) { step in
            Color.clear
                .overlay { OnboardingArtwork(step) }
                .frame(width: 240, height: 360)
                .clipped()
                .border(.borderDefault)
        }
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.lg) {
        ForEach(OnboardingStep.allCases.filter(\.hasArtwork), id: \.self) { step in
            Color.clear
                .overlay { OnboardingArtwork(step) }
                .frame(width: 240, height: 360)
                .clipped()
        }
    }
    .padding(Spacing.xxl)
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}
#endif
