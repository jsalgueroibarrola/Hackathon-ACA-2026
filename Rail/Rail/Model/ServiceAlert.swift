import Foundation
import SwiftData

@Model
final class ServiceAlert {
    var id: String
    var kindRaw: String
    var lineIDs: [String]
    var since: Date?
    var until: Date?
    var text: String
    var position: Int

    var feed: ServiceAlertFeed?

    init(
        id: String,
        kind: AlertKind,
        lineIDs: [String],
        since: Date?,
        until: Date?,
        text: String,
        position: Int
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.lineIDs = lineIDs
        self.since = since
        self.until = until
        self.text = text
        self.position = position
    }
}

extension ServiceAlert {
    var kind: AlertKind {
        AlertKind(rawValue: kindRaw) ?? .other
    }
}

enum AlertKind: String, Codable, CaseIterable, Sendable {
    case notice
    case info
    case other
}
