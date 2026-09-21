//
//  StationCallout.swift
//  Rail
//
//  Created by jakuru on 21/09/2026.
//

import SwiftUI

struct StationCallout: View {
    let pin: StationPin
    var onDismiss: () -> Void
    var onOpenDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(pin.name)
                    .font(.headline)

                Spacer()

                Button(action: onDismiss) {
                    Label("Cerrar", systemImage: "xmark")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            }

            if !pin.lineIDs.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(zip(pin.lineIDs, pin.colorHexes)), id: \.0) {
                        id,
                        hex in
                        Text(id)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(hex: hex), in: .capsule)
                    }
                }
            }

            HStack(spacing: 6) {
                if pin.isAccessible {
                    BadgeIcon(
                        systemName: StationAccessibilitySymbol.reducedMobility,
                        tint: .blue,
                        diameter: 22
                    )
                }
                if pin.hasElevator {
                    BadgeIcon(
                        systemName: StationAccessibilitySymbol.elevator,
                        tint: .gray,
                        diameter: 22
                    )
                }
                ForEach(pin.connections, id: \.self) { connection in
                    BadgeIcon(
                        systemName: connection.symbolName,
                        tint: connection.tint,
                        diameter: 22
                    )
                }
            }

            Button("Ver detalle", action: onOpenDetail)
                .font(.subheadline.weight(.semibold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: .rect(cornerRadius: 18))
    }
}

// MARK: - Previews

extension StationPin {
    fileprivate static let calloutPlain = StationPin(
        id: "principe-asturias",
        name: "Príncipe de Asturias",
        latitude: 36.7114,
        longitude: -4.4412,
        lineIDs: ["L1"],
        colorHexes: ["E1251B"]
    )

    fileprivate static let calloutAccessible = StationPin(
        id: "portada-alta",
        name: "Portada Alta",
        latitude: 36.7185,
        longitude: -4.4620,
        isAccessible: true,
        hasElevator: true,
        lineIDs: ["L2"],
        colorHexes: ["5C2D91"]
    )

    fileprivate static let calloutInterchange = StationPin(
        id: "guadalmedina",
        name: "Guadalmedina",
        latitude: 36.7203,
        longitude: -4.4291,
        isAccessible: true,
        connections: [.urbanBus],
        lineIDs: ["L1", "L2"],
        colorHexes: ["E1251B", "5C2D91"]
    )

    fileprivate static let calloutHub = StationPin(
        id: "el-perchel",
        name: "El Perchel",
        latitude: 36.7139,
        longitude: -4.4322,
        isAccessible: true,
        hasElevator: true,
        connections: [.ave, .regional, .busStation, .interurbanBus, .airport],
        lineIDs: ["L1", "L2"],
        colorHexes: ["E1251B", "5C2D91"]
    )

    fileprivate static let calloutLongName = StationPin(
        id: "andalucia-tech",
        name: "Universidad de Málaga – Andalucía Tech",
        latitude: 36.7154,
        longitude: -4.4790,
        isAccessible: true,
        connections: [.urbanBus, .interurbanBus],
        lineIDs: ["L1"],
        colorHexes: ["E1251B"]
    )
}

extension StationPin {
    fileprivate static let calloutSamples: [StationPin] = [
        .calloutInterchange, .calloutHub, .calloutPlain, .calloutAccessible,
    ]
}

extension LineOverlay {
    fileprivate static let calloutLine = LineOverlay(
        id: "L1",
        name: "Andalucía Tech – Atarazanas",
        colorHex: "E1251B",
        coordinates: StationPin.calloutSamples.map(\.coordinate)
    )
}

private struct CalloutBackdrop<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "DCE7D5"), Color(hex: "EFEAE0")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
                .padding(16)
        }
    }
}

#Preview("Estados") {
    CalloutBackdrop {
        VStack(spacing: 16) {
            StationCallout(pin: .calloutPlain, onDismiss: {}, onOpenDetail: {})
            StationCallout(
                pin: .calloutAccessible,
                onDismiss: {},
                onOpenDetail: {}
            )
            StationCallout(
                pin: .calloutInterchange,
                onDismiss: {},
                onOpenDetail: {}
            )
            StationCallout(pin: .calloutHub, onDismiss: {}, onOpenDetail: {})
        }
    }
}

#Preview("Nombre largo") {
    CalloutBackdrop {
        StationCallout(pin: .calloutLongName, onDismiss: {}, onOpenDetail: {})
    }
}

#Preview("Sobre el mapa") {
    @Previewable @State var selection: String? = "el-perchel"

    ZStack(alignment: .bottom) {
        NetworkMap(
            lines: [.calloutLine],
            pins: StationPin.calloutSamples,
            selection: $selection
        )
        .ignoresSafeArea()

        StationCallout(
            pin: .calloutHub,
            onDismiss: { selection = nil },
            onOpenDetail: {}
        )
        .padding(16)
    }
}

#Preview("Dynamic Type") {
    CalloutBackdrop {
        StationCallout(pin: .calloutHub, onDismiss: {}, onOpenDetail: {})
    }
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Modo oscuro") {
    CalloutBackdrop {
        VStack(spacing: 16) {
            StationCallout(pin: .calloutPlain, onDismiss: {}, onOpenDetail: {})
            StationCallout(pin: .calloutHub, onDismiss: {}, onOpenDetail: {})
        }
    }
    .preferredColorScheme(.dark)
}
