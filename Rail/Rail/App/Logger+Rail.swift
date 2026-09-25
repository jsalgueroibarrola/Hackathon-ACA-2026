import OSLog

extension Logger {
    static let liveFeeds = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "LiveFeeds"
    )

    static let userStations = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "UserStations"
    )
}
