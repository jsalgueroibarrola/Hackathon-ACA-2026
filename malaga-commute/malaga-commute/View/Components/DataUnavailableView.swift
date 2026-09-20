//
//  DataUnavailableView.swift
//  malaga-commute
//
//  Created by jakuru on 20/09/2026.
//

import SwiftUI

struct DataUnavailableView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No hay horarios disponibles", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Reintentar", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    DataUnavailableView(message: "The Internet connection appears to be offline.") {}
}
