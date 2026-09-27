import SwiftUI

struct TrainMarker: View {
    let tint: LineTint
    let rotation: Angle
    var isStale = false

    @ScaledMetric(relativeTo: .caption) private var diameter: CGFloat = Size.iconMd

    var body: some View {
        ZStack {
            ZStack {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: diameter * 0.62))
                    .foregroundStyle(.background)
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: diameter * 0.42))
                    .foregroundStyle(tint.base)
            }
            .offset(y: -diameter * 0.7)
            .rotationEffect(rotation)

            Image(systemName: "tram.fill")
                .font(.system(size: diameter * 0.5, weight: .semibold))
                .foregroundStyle(tint.text)
                .frame(width: diameter, height: diameter)
                .background(tint.base, in: .circle)
                .background {
                    if !isStale {
                        PulseRing(Circle())
                            .tint(tint.base)
                    }
                }
                .overlay {
                    Circle().strokeBorder(.background, lineWidth: Border.thick)
                }
                .elevation(.floating)
        }
        .frame(width: diameter * 1.9, height: diameter * 1.9)
        .opacity(isStale ? 0.5 : 1)
        .accessibilityElement(children: .ignore)
    }
}

#if DEBUG
#Preview("Direcciones") {
    HStack(spacing: Spacing.xxl) {
        ForEach([0.0, 90, 200, 315], id: \.self) { degrees in
            TrainMarker(
                tint: LineTint(base: Color(hex: "DA291C")),
                rotation: .degrees(degrees)
            )
        }
        TrainMarker(
            tint: LineTint(base: Color(hex: "0057A8")),
            rotation: .degrees(45),
            isStale: true
        )
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
}

#Preview("Modo oscuro") {
    HStack(spacing: Spacing.xxl) {
        TrainMarker(tint: LineTint(base: Color(hex: "DA291C")), rotation: .degrees(30))
        TrainMarker(tint: LineTint(base: Color(hex: "0057A8")), rotation: .degrees(210))
    }
    .padding(Spacing.xxl)
    .background(.bgPrimary)
    .preferredColorScheme(.dark)
}

#Preview("Dynamic Type") {
    TrainMarker(tint: LineTint(base: Color(hex: "DA291C")), rotation: .degrees(60))
        .padding(Spacing.xxl)
        .background(.bgPrimary)
        .dynamicTypeSize(.accessibility2)
}
#endif
