import Foundation

extension Date.FormatStyle {
    static func departureTime(in timeZone: TimeZone) -> Date.FormatStyle {
        Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
    }
}
