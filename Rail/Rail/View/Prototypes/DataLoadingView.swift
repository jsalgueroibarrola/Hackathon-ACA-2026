//
//  DataLoadingView.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI

struct DataLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)

            Text("Descargando horarios")
                .font(.headline)

            Text("Solo ocurre la primera vez o cuando los datos caducan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DataLoadingView()
}
