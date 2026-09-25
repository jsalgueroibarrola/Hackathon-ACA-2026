import WidgetKit

enum WidgetReloader {
    static func reloadNextTrains() {
        WidgetCenter.shared.reloadTimelines(
            ofKind: RailWidgetLink.nextTrainsKind
        )
    }
}
