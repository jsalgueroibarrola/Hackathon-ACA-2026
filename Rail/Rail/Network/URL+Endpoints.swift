import Foundation

private let apiBaseURL: URL = {
    guard
        let value = Bundle.main.object(forInfoDictionaryKey: "RailAPIBaseURL") as? String,
        let url = URL(string: value)
    else {
        preconditionFailure("RailAPIBaseURL is missing from Info.plist")
    }
    return url
}()

private let apiMalagaURL: URL = apiBaseURL.appending(path: "malaga")

extension URL {
    static let network: URL = apiMalagaURL.appending(path: "network")

    static let timetable: URL = apiMalagaURL.appending(path: "timetable")

    static let alerts: URL = apiMalagaURL.appending(path: "alerts")

    static let realtime: URL = apiMalagaURL.appending(path: "realtime")
}
