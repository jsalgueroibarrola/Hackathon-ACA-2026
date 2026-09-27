import SwiftUI

struct PulseRing: View {
    private let outline: AnyShape

    init(_ outline: some Shape) {
        self.outline = AnyShape(outline)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                PulseWave.ring(outline, progress: Self.restingProgress)
            } else {
                PulseWave(outline: outline)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private static let restingProgress = 0.4
}

private struct PulseWave: View {
    let outline: AnyShape

    @State private var progress = 0.0

    var body: some View {
        outline
            .fill(.tint)
            .animation(
                .easeOut(duration: Self.period)
                    .repeatForever(autoreverses: false)
            ) { ring in
                Self.pulse(ring, progress: progress)
            }
            .task { progress = 1 }
    }

    static func ring(_ outline: AnyShape, progress: Double) -> some View {
        pulse(outline.fill(.tint), progress: progress)
    }

    private static func pulse(_ ring: some View, progress: Double) -> some View {
        ring
            .modifier(PulseSpread(progress: progress, spread: spread))
            .opacity(peakOpacity * (1 - progress))
    }

    private static let period: TimeInterval = 3.2
    private static let spread: CGFloat = 30
    private static let peakOpacity = 0.45
}

@Animatable
private struct PulseSpread: GeometryEffect {
    var progress: Double
    @AnimatableIgnored var spread: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let inset = spread * progress
        return ProjectionTransform(
            CGAffineTransform(translationX: -inset, y: -inset)
                .scaledBy(
                    x: size.width > 0 ? 1 + 2 * inset / size.width : 1,
                    y: size.height > 0 ? 1 + 2 * inset / size.height : 1
                )
        )
    }
}

#if DEBUG
private struct PulseRingSample: View {
    var body: some View {
        VStack(spacing: 96) {
            StationDot(color: Color(hex: "DA291C"), size: 18)
                .background {
                    PulseRing(Circle())
                }
            Capsule()
                .fill(.background)
                .frame(width: 48, height: 28)
                .background {
                    PulseRing(Capsule())
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgSecondary)
    }
}

#Preview("Pulso") {
    PulseRingSample()
}

#Preview("Modo oscuro") {
    PulseRingSample()
        .preferredColorScheme(.dark)
}
#endif
