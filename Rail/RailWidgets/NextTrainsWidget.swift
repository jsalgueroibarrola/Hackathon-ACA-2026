import SwiftUI
import WidgetKit

struct NextTrainsWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: RailWidgetLink.nextTrainsKind,
            intent: SelectFavoriteStationIntent.self,
            provider: NextTrainsWidgetProvider()
        ) { entry in
            NextTrainsWidgetView(entry: entry)
        }
        .configurationDisplayName(
            LocalizedStringResource(
                "Próximos trenes",
                comment: "Nombre del widget en la galería de widgets."
            )
        )
        .description(
            LocalizedStringResource(
                "Los próximos trenes en una de tus estaciones favoritas.",
                comment: "Descripción del widget en la galería de widgets."
            )
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
        ])
    }
}

