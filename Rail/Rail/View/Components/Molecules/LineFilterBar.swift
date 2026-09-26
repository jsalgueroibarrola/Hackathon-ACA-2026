import SwiftUI

struct LineFilterBar: View {
    private let lineIDs: [String]
    @Binding private var selection: String?

    init(_ lineIDs: [String], selection: Binding<String?>) {
        self.lineIDs = lineIDs
        _selection = selection
    }

    var body: some View {
        ScrollView(.horizontal) {
            GlassEffectContainer(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    chip(nil)
                    ForEach(lineIDs, id: \.self) { lineID in
                        chip(lineID)
                    }
                }
                .padding(.horizontal, ScreenLayout.margin)
                .padding(.vertical, Spacing.sm)
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private func chip(_ lineID: String?) -> some View {
        Button {
            selection = lineID
        } label: {
            if let lineID {
                Text(verbatim: lineID)
            } else {
                Text(Self.allLinesTitle)
            }
        }
        .buttonStyle(.filterChip(isSelected: selection == lineID))
    }

    private static let allLinesTitle = LocalizedStringResource(
        "Todas",
        comment: "Selector de estación y pantalla Estaciones: filtro que muestra las estaciones de todas las líneas."
    )
}

#Preview {
    @Previewable @State var selection: String?
    LineFilterBar(["C-1", "C-2"], selection: $selection)
        .background(.bgSecondary)
}
