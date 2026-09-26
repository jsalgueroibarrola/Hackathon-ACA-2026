import SwiftUI

struct HomeHeroImage: View {
    var body: some View {
        Color.clear
            .overlay {
                Image(.homeHero)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

#if DEBUG
private struct HomeHeroImageSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            HomeHeroImage()
                .frame(width: 393, height: 262)
            HomeHeroImage()
                .frame(width: 393, height: 160)
            HomeHeroImage()
                .frame(width: 200, height: 262)
        }
        .padding(Spacing.xxl)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    ScrollView {
        HomeHeroImageSamples()
    }
    .background(.bgSecondary)
}

#Preview("Modo oscuro") {
    ScrollView {
        HomeHeroImageSamples()
    }
    .background(.bgSecondary)
    .preferredColorScheme(.dark)
}
#endif
