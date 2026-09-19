//
//  ContentView.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Line.id) private var lines: [Line]

    var body: some View {
        NavigationStack {
            List(lines) { line in
                VStack(alignment: .leading) {
                    Text(line.id)
                        .font(.headline)
                    Text(line.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                if lines.isEmpty {
                    ContentUnavailableView("Sin datos de red", systemImage: "tram")
                }
            }
            .navigationTitle("Líneas")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransitNetwork.self, inMemory: true)
}
