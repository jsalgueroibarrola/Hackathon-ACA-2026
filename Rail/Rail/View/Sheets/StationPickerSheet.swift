import SwiftData
import SwiftUI

enum StationPickerMode {
    case pick(selection: Set<String>, onPick: (String) -> Void)
    case favorites
}

struct StationPickerSheet<Header: View>: View {
    private let mode: StationPickerMode
    private let header: Header

    @Environment(\.dismiss) private var dismiss
    @Environment(LocationViewModel.self) private var location
    @Query private var lines: [Line]
    @Query private var favorites: [FavoriteStation]
    @State private var query = ""
    @State private var lineFilter: String?

    init(_ mode: StationPickerMode, @ViewBuilder header: () -> Header) {
        self.mode = mode
        self.header = header()
    }

    init(
        selection: Set<String> = [],
        onPick: @escaping (String) -> Void,
        @ViewBuilder header: () -> Header
    ) {
        self.init(.pick(selection: selection, onPick: onPick), header: header)
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
            let favoriteIDs = Set(favorites.map(\.stationID))
            List {
                header
                ForEach(sections) { section in
                    Section {
                        ForEach(section.items) { item in
                            row(
                                item,
                                isFavorite: favoriteIDs.contains(item.id),
                                showsSeparator: item.id != section.items.last?.id
                            )
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
            .navigationTitle(title)
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

    private var title: LocalizedStringResource {
        switch mode {
        case .pick: Self.pickTitle
        case .favorites: Self.favoritesTitle
        }
    }

    private func row(
        _ item: StationRowItem,
        isFavorite: Bool,
        showsSeparator: Bool
    ) -> some View {
        Group {
            switch mode {
            case let .pick(selection, onPick):
                pickRow(
                    item,
                    isSelected: selection.contains(item.id),
                    showsSeparator: showsSeparator,
                    onPick: onPick
                )
            case .favorites:
                FavoriteToggleRow(
                    item: item,
                    isFavorite: isFavorite,
                    showsSeparator: showsSeparator
                )
            }
        }
        .listRowInsets(StationRow.listRowInsets)
        .listRowSeparator(.hidden)
    }

    private func pickRow(
        _ item: StationRowItem,
        isSelected: Bool,
        showsSeparator: Bool,
        onPick: @escaping (String) -> Void
    ) -> some View {
        Button {
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
    }

    private static var pickTitle: LocalizedStringResource {
        LocalizedStringResource(
            "Elegir estación",
            comment: "Selector de estación: título de la hoja para añadir una favorita o elegir la estación habitual."
        )
    }

    private static var favoritesTitle: LocalizedStringResource {
        LocalizedStringResource(
            "Elegir estaciones",
            comment: "Selector de estación: título de la hoja en la que se marcan varias favoritas con la estrella, desde la bienvenida."
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
    init(_ mode: StationPickerMode) {
        self.init(mode) {
            EmptyView()
        }
    }

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

#Preview("Favoritas", traits: .favoriteStationsSampleData) {
    StationPickerSheet(.favorites)
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
