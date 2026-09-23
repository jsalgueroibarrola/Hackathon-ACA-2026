import SwiftUI

extension LineMark {
    init(_ tag: LineTag) {
        self.init(tag.id, color: Color(hex: tag.colorHex))
    }
}

extension StationRow {
    init(
        _ item: StationRowItem,
        isFavorite: Binding<Bool>? = nil,
        showsSeparator: Bool = true
    ) {
        self.init(
            name: item.name,
            subtitle: item.subtitle,
            lines: item.lines.map(LineMark.init),
            isFavorite: isFavorite,
            showsSeparator: showsSeparator
        )
    }
}

extension FavoriteStationCard {
    init(_ item: StationRowItem) {
        self.init(
            name: item.name,
            subtitle: item.subtitle,
            lines: item.lines.map(LineMark.init)
        )
    }
}
