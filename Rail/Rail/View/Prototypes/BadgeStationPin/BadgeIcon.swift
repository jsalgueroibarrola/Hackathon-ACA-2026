import SwiftUI

struct BadgeIcon: View {
    let systemName: String
    let tint: Color
    let diameter: CGFloat

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: diameter * 0.55, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(tint, in: .circle)
            .overlay(
                Circle().strokeBorder(.background, lineWidth: diameter * 0.08)
            )
            .shadow(color: .black.opacity(0.2), radius: 1, y: 0.5)
    }
}

#if DEBUG
private struct BadgeIconRow: View {
    let title: String
    let systemName: String
    let tint: Color
    var diameter: CGFloat = 26

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)

            BadgeIcon(systemName: systemName, tint: tint, diameter: diameter)
        }
    }
}

#Preview("Símbolos") {
    VStack(alignment: .leading, spacing: 20) {
        BadgeIconRow(
            title: "Movilidad reducida",
            systemName: StationAccessibilitySymbol.reducedMobility,
            tint: StationPin.accessibleTint
        )
        BadgeIconRow(
            title: "Ascensor",
            systemName: StationAccessibilitySymbol.elevator,
            tint: StationPin.elevatorTint
        )
        BadgeIconRow(title: "Aeropuerto", systemName: "airplane", tint: .indigo)
        BadgeIconRow(title: "AVE", systemName: "train.side.front.car", tint: .purple)
        BadgeIconRow(title: "Autobús urbano", systemName: "bus", tint: .orange)
        BadgeIconRow(title: "Metro", systemName: "tram.fill.tunnel", tint: .green)
    }
    .padding(32)
}

#Preview("Tamaños") {
    VStack(alignment: .leading, spacing: 20) {
        ForEach([10, 14, 20, 26, 40, 64] as [CGFloat], id: \.self) { diameter in
            BadgeIconRow(
                title: "\(Int(diameter)) pt",
                systemName: StationAccessibilitySymbol.reducedMobility,
                tint: StationPin.accessibleTint,
                diameter: diameter
            )
        }
    }
    .padding(32)
}

#Preview("Sobre el punto") {
    HStack(spacing: 40) {
        ForEach([ZoomBucket.region, .street, .detail], id: \.self) { zoom in
            StationDot(color: Color(hex: "E1251B"), size: zoom.dotSize)
                .overlay(alignment: .topTrailing) {
                    BadgeIcon(
                        systemName: StationAccessibilitySymbol.reducedMobility,
                        tint: StationPin.accessibleTint,
                        diameter: zoom.dotSize * 0.62
                    )
                    .offset(x: zoom.dotSize * 0.3, y: -zoom.dotSize * 0.3)
                }
        }
    }
    .padding(40)
}

#Preview("Sobre fondos") {
    VStack(spacing: 0) {
        ForEach(
            [Color.white, Color(hex: "DCE7D5"), Color(hex: "1C1C1E"), Color.blue],
            id: \.self
        ) { background in
            HStack(spacing: 20) {
                BadgeIcon(
                    systemName: StationAccessibilitySymbol.reducedMobility,
                    tint: StationPin.accessibleTint,
                    diameter: 26
                )
                BadgeIcon(
                    systemName: StationAccessibilitySymbol.elevator,
                    tint: StationPin.elevatorTint,
                    diameter: 26
                )
                BadgeIcon(systemName: "airplane", tint: .indigo, diameter: 26)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(background)
        }
    }
}

#Preview("Modo oscuro") {
    VStack(alignment: .leading, spacing: 20) {
        BadgeIconRow(
            title: "Movilidad reducida",
            systemName: StationAccessibilitySymbol.reducedMobility,
            tint: StationPin.accessibleTint
        )
        BadgeIconRow(title: "AVE", systemName: "train.side.front.car", tint: .purple)
        BadgeIconRow(title: "Grande", systemName: "airplane", tint: .indigo, diameter: 48)
    }
    .padding(32)
    .preferredColorScheme(.dark)
}
#endif
