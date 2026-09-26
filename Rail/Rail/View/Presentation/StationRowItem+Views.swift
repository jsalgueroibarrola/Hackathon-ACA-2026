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
        favoriteEdge: HorizontalEdge = .trailing,
        accessory: Accessory = .chevron,
        showsSeparator: Bool = true
    ) {
        self.init(
            name: item.name,
            subtitle: item.subtitle,
            lines: item.lines.map(LineMark.init),
            distance: item.distance,
            isFavorite: isFavorite,
            favoriteEdge: favoriteEdge,
            accessory: accessory,
            showsSeparator: showsSeparator
        )
    }
}

extension FavoriteStationCard {
    init(_ item: StationRowItem, isFavorite: Binding<Bool>? = nil) {
        self.init(
            name: item.name,
            subtitle: item.subtitle,
            lines: item.lines.map(LineMark.init),
            distance: item.distance,
            isFavorite: isFavorite
        )
    }
}
