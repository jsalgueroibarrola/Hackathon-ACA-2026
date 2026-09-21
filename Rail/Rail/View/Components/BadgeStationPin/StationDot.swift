//
//  StationDot.swift
//  Rail
//
//  Created by jakuru on 21/09/2026.
//

import SwiftUI

struct StationDot: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(.background)
            .shadow(color: .black.opacity(0.25), radius: 1.5, y: 0.5)
            .overlay {
                Circle()
                    .stroke(color, lineWidth: size * 0.3)
                    .padding(size * 0.15)
            }
            .frame(width: size, height: size)
    }
}

// MARK: - Previews

private struct StationDotRow: View {
    let title: String
    let color: Color
    var size: CGFloat = 20

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)

            StationDot(color: color, size: size)
        }
    }
}

#Preview("Colores") {
    VStack(alignment: .leading, spacing: 20) {
        StationDotRow(title: "L1", color: Color(hex: "E1251B"))
        StationDotRow(title: "L2", color: Color(hex: "5C2D91"))
        StationDotRow(
            title: "Intercambiador",
            color: StationPin.interchangeColor
        )
        StationDotRow(title: "Sin color", color: Color(hex: ""))
    }
    .padding(32)
}

#Preview("Tamaños") {
    VStack(alignment: .leading, spacing: 20) {
        ForEach(ZoomBucket.allCases.reversed(), id: \.self) { zoom in
            StationDotRow(
                title: "\(zoom) · \(Int(zoom.dotSize)) pt",
                color: Color(hex: "E1251B"),
                size: zoom.dotSize
            )
        }
        StationDotRow(
            title: "seleccionado · 27 pt",
            color: Color(hex: "E1251B"),
            size: ZoomBucket.detail.dotSize * 1.35
        )
    }
    .padding(32)
}

#Preview("Sobre fondos") {
    VStack(spacing: 0) {
        ForEach(
            [
                Color.white, Color(hex: "DCE7D5"), Color(hex: "1C1C1E"),
                Color.blue,
            ],
            id: \.self
        ) { background in
            HStack(spacing: 24) {
                StationDot(color: Color(hex: "E1251B"), size: 20)
                StationDot(color: Color(hex: "5C2D91"), size: 20)
                StationDot(color: StationPin.interchangeColor, size: 20)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(background)
        }
    }
}

#Preview("Modo oscuro") {
    VStack(alignment: .leading, spacing: 20) {
        StationDotRow(title: "L1", color: Color(hex: "E1251B"))
        StationDotRow(title: "L2", color: Color(hex: "5C2D91"))
        StationDotRow(title: "Grande", color: Color(hex: "E1251B"), size: 48)
    }
    .padding(32)
    .preferredColorScheme(.dark)
}
