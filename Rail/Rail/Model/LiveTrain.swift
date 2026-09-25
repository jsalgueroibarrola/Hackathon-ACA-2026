import Foundation
import SwiftData

@Model
final class LiveTrain {
    #Index<LiveTrain>([\.lineID, \.train])

    var lineID: String
    var train: String
    var serviceDay: Date?
    var delaySeconds: Int?
    var statusRaw: String
    var stopID: String?
    var nextStopID: String?
    var latitude: Double?
    var longitude: Double?
    var platform: String?
    var sampledAt: Date?

    var feed: RealtimeFeed?

    init(
        lineID: String,
        train: String,
        serviceDay: Date?,
        delaySeconds: Int?,
        status: LiveStatus,
        stopID: String?,
        nextStopID: String?,
        latitude: Double?,
        longitude: Double?,
        platform: String?,
        sampledAt: Date?
    ) {
        self.lineID = lineID
        self.train = train
        self.serviceDay = serviceDay
        self.delaySeconds = delaySeconds
        self.statusRaw = status.rawValue
        self.stopID = stopID
        self.nextStopID = nextStopID
        self.latitude = latitude
        self.longitude = longitude
        self.platform = platform
        self.sampledAt = sampledAt
    }
}

extension LiveTrain {
    var status: LiveStatus {
        LiveStatus(rawValue: statusRaw) ?? .unknown
    }
}

enum LiveStatus: String, Codable, CaseIterable, Sendable {
    case at
    case left
    case approaching
    case unknown
}
