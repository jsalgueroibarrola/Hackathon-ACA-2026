import SwiftData
import SwiftUI

struct StationPickerSheet<Header: View>: View {
    private let selection: Set<String>
    private let onPick: (String) -> Void
    private let header: Header

    @Environment(\.dismiss) private var dismiss
    @Environment(LocationViewModel.self) private var location
    @Query private var lines: [Line]
    @State private var query = ""
    @State private var lineFilter: String?

    init(
        selection: Set<String> = [],
        onPick: @escaping (String) -> Void,
        @ViewBuilder header: () -> Header
    ) {
        self.selection = selection
        self.onPick = onPick
        self.header = header()
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var sections: [StationPickerSection] {
        StationPickerSectionBuilder.sections(
            lines: lines,
            query: query,
            lineFilter: lineFilter,
            location: location.location
        )
    }

    var body: some View {
        NavigationStack {
            let sections = sections
            List {
                header
                ForEach(sections) { section in
                    Section {
                        ForEach(section.items) { item in
                            row(item, showsSeparator: item.id != section.items.last?.id)
                        }
                    } header: {
                        StationSectionHeader(section.title)
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(Spacing.md)
            .contentMargins(.top, 0, for: .scrollContent)
            .overlay {
                if sections.isEmpty && !trimmedQuery.isEmpty {
                    StationSearchNoResults(trimmedQuery)
                }
            }
            .safeAreaBar(edge: .top) {
                LineFilterBar(
                    StationPickerSectionBuilder.lineIDs(lines),
                    selection: $lineFilter
                )
            }
            .searchable(text: $query, prompt: Text(Self.searchPrompt))
            .navigationTitle(Self.title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private func row(_ item: StationRowItem, showsSeparator: Bool) -> some View {
        let isSelected = selection.contains(item.id)
        return Button {
            onPick(item.id)
            dismiss()
        } label: {
            StationRow(
                item,
                accessory: isSelected ? .checkmark : .hidden,
                showsSeparator: showsSeparator
            )
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .listRowInsets(StationRow.listRowInsets)
        .listRowSeparator(.hidden)
    }

    private static var title: LocalizedStringResource {
        LocalizedStringResource(
            "Elegir estación",
            comment: "Selector de estación: título de la hoja para añadir una favorita o elegir la estación habitual."
        )
    }

    private static var searchPrompt: LocalizedStringResource {
        LocalizedStringResource(
            "Buscar estación",
            comment: "Selector de estación: texto de ayuda del campo de búsqueda."
        )
    }
}

extension StationPickerSheet where Header == EmptyView {
    init(selection: Set<String> = [], onPick: @escaping (String) -> Void) {
        self.init(selection: selection, onPick: onPick) {
            EmptyView()
        }
    }
}

#if DEBUG
#Preview("Variantes Figma", traits: .favoriteStationsSampleData) {
    StationPickerSheet(selection: ["54404"]) { _ in }
        .environment(LocationViewModel.preview(authorization: .denied))
}

#Preview("Con ubicación", traits: .favoriteStationsSampleData) {
    StationPickerSheet { _ in }
        .environment(LocationViewModel.preview(location: .alameda))
}

#Preview("Modo oscuro", traits: .favoriteStationsSampleData) {
    StationPickerSheet(selection: ["54413"]) { _ in }
        .environment(LocationViewModel.preview(authorization: .denied))
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type", traits: .favoriteStationsSampleData) {
    StationPickerSheet { _ in }
        .environment(LocationViewModel.preview(location: .alameda))
        .dynamicTypeSize(.accessibility2)
}
#endif
