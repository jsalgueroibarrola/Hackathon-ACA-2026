import OSLog

extension Logger {
    static let liveFeeds = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "LiveFeeds"
    )

    static let schedules = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "Schedules"
    )

    static let sync = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "Sync"
    )

    static let userStations = Logger(
        subsystem: "com.JadeHorizonStudio.Rail",
        category: "UserStations"
    )
}
