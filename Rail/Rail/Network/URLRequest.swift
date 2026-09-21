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
        timeout: TimeInterval = 30
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeout

        if let etag {
            request.addValue(etag, forHTTPHeaderField: "If-None-Match")
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }

        return request
    }
}
