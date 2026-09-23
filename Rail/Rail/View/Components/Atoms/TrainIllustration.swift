import SwiftUI

struct TrainIllustration: View {
    var body: some View {
        Image(.trenecitoInicio)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

private struct TrainIllustrationSamples: View {
    var body: some View {
        VStack(spacing: Spacing.xxl) {
            TrainIllustration()
                .frame(height: 53)
                .padding(Spacing.md)
                .background(.bgPrimary)
            ZStack(alignment: .topTrailing) {
                Color.bgPrimary
                TrainIllustration()
                    .frame(height: 53)
                    .padding(.top, 17)
            }
            .frame(width: 360, height: 90)
            .clipShape(.rect(cornerRadius: Radius.md, style: .continuous))
        }
        .padding(Spacing.xxl)
        .background(.bgSecondary)
    }
}

#Preview("Variantes Figma") {
    TrainIllustrationSamples()
}

#Preview("Modo oscuro") {
    TrainIllustrationSamples()
        .preferredColorScheme(.dark)
}
