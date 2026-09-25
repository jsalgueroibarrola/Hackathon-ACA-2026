import WidgetKit

extension WidgetFamily {
    var maxDepartures: Int {
        switch self {
        case .systemSmall: 2
        case .systemMedium: 3
        case .systemLarge: 7
        case .accessoryRectangular: 2
        default: 1
        }
    }
}
