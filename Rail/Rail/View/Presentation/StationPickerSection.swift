import Foundation

struct StationPickerSection: Identifiable, Hashable, Sendable {
    let lineID: String
    let items: [StationRowItem]

    var id: String { lineID }
}

extension StationPickerSection {
    var title: LocalizedStringResource {
        LocalizedStringResource(
            "Línea \(lineID)",
            comment: "Selector de estación y pantalla Estaciones: cabecera de la sección con las estaciones de una línea, por ejemplo «Línea C1»."
        )
    }
}

enum StationPickerSectionBuilder {
    static func lineIDs(_ lines: [Line]) -> [String] {
        sorted(lines).map(\.id)
    }

    static func sections(
        lines: [Line],
        query: String,
        lineFilter: String?,
        location: UserLocation?
    ) -> [StationPickerSection] {
        sorted(lines)
            .filter { lineFilter == nil || $0.id == lineFilter }
            .map { line in
                StationPickerSection(
                    lineID: line.id,
                    items: line.orderedStops
                        .compactMap(\.station)
                        .filter { matches($0, query: query) }
                        .map { StationRowItemBuilder.item(for: $0, location: location) }
                )
            }
            .filter { !$0.items.isEmpty }
    }

    static func matches(_ station: Station, query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty
            || station.name.localizedStandardContains(query)
            || station.lines.contains { normalized($0.id) == normalized(query) }
    }

    private static func sorted(_ lines: [Line]) -> [Line] {
        lines.sorted {
            $0.id.localizedStandardCompare($1.id) == .orderedAscending
        }
    }

    private static func normalized(_ text: String) -> String {
        String(
            text.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: nil
            )
            .filter { $0.isLetter || $0.isNumber }
        )
    }
}
