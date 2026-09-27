import WidgetKit

extension WidgetFamily {
    var maxDepartures: Int {
        switch self {
        case .systemSmall: 1
        case .systemMedium: 4
        case .systemLarge: 12        default: 1
        }
    }
}
