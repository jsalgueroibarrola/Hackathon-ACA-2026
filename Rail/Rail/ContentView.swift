//
//  ContentView.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Line.id) private var lines: [Line]
    @Environment(\.routeShapes) private var routeShapes

    var body: some View {
        NavigationStack {
            List(lines) { line in
                NavigationLink {
                    LineDetailView(line: line)
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: line.colorHex))
                            .frame(width: 6)
                        VStack(alignment: .leading) {
                            Text(line.id)
                                .font(.headline)
                            Text(line.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 44)
                }
            }
            .overlay {
                if lines.isEmpty {
                    ContentUnavailableView("Sin datos de red", systemImage: "tram")
                }
            }
            .navigationTitle("Líneas")
        }
        .task(id: lines.map(\.shape)) {
            await routeShapes.warm(lines.map(\.routeShape))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: RailSchema.models, inMemory: true)
}
