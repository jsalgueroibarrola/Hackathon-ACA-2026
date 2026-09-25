import SwiftUI

extension IncidentCard {
    init(
        _ item: ServiceAlertItem,
        description: String,
        @ViewBuilder action: () -> Action
    ) {
        self.init(
            item.kind.severity,
            label: item.kind.badgeLabel,
            title: String(localized: item.kind.title),
            description: description,
            time: item.time,
            lines: item.lines.map(LineMark.init),
            action: action
        )
    }
}
