//
//  URLRequest.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

extension URLRequest {
    static func request(
        url: URL,
        method: HTTPMethod = .get,
        etag: String? = nil,
        timeout: TimeInterval = 10
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = timeout
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let etag {
            request.addValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        return request
    }
}
