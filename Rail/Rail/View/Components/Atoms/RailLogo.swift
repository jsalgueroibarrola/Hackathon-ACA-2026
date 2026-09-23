import SwiftUI

struct RailLogo: View {
    var body: some View {
        Image(.railLogo)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

private struct RailLogoSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            HStack(spacing: Spacing.xxl) {
                RailLogo()
                    .frame(height: Size.touchMin)
                RailLogo()
                    .frame(height: 88)
            }
            .padding(Spacing.md)
            .background(.bgPrimary)
            ZStack(alignment: .topLeading) {
                HomeHeroImage()
                RailLogo()
                    .frame(height: Size.touchMin)
                    .padding(.leading, ScreenLayout.margin)
                    .padding(.top, Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        }
        .padding(Spacing.xxl)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    RailLogoSamples()
}

#Preview("Modo oscuro") {
    RailLogoSamples()
        .preferredColorScheme(.dark)
}
