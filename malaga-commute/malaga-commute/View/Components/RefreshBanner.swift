//
//  RefreshBanner.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI

struct RefreshBanner: View {
    let lastFetchedAt: Date?

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassEffect(.regular.tint(.orange.opacity(0.3)), in: .capsule)
            .padding(.bottom, 8)
    }

    private var message: LocalizedStringResource {
        guard let lastFetchedAt else {
            return "No se han podido actualizar los horarios"
        }
        return "Última actualización: \(lastFetchedAt, format: .relative(presentation: .named))"
    }
}

#Preview {
    RefreshBanner(lastFetchedAt: .now.addingTimeInterval(-90_000))
}
