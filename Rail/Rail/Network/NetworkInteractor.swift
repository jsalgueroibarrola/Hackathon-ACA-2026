import Foundation
import SwiftUI

protocol NetworkInteractor: Sendable {}

extension NetworkInteractor {

    @concurrent
    func getJSON<JSON>(request: URLRequest, type: JSON.Type)
        async throws(NetworkError) -> ETagged<JSON> where JSON: Decodable & Sendable {
        let (data, response) = try await URLSession.shared.getData(for: request)

        switch response.statusCode {
        case 200: break
        case 304: throw NetworkError.notModified(response.cacheFreshness)
        case 503: throw NetworkError.serviceUnavailable(retryAfter: response.retryAfter)
        default: throw NetworkError.status(response.statusCode)
        }

        do {
            let value = try JSONDecoder().decode(type, from: data)
            return ETagged(
                value: value,
                etag: response.value(forHTTPHeaderField: "ETag"),
                freshness: response.cacheFreshness
            )
        } catch {
            throw NetworkError.json(error)
        }
    }
}
