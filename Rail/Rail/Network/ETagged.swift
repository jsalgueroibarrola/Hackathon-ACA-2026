import Foundation

struct ETagged<Value: Sendable>: Sendable {
    let value: Value
    let etag: String?
    var freshness: CacheFreshness = .unknown
}
