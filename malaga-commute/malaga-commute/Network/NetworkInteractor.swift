//
//  NetworkInteractor.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//
import Foundation
import SwiftUI

protocol NetworkInteractor: Sendable {}

extension NetworkInteractor {

    @concurrent
    func getJSON<JSON>(request: URLRequest, type: JSON.Type)
        async throws(NetworkError) -> ETagged<JSON> where JSON: Decodable & Sendable {
        let (data, response) = try await URLSession.shared.getData(for: request)

        if response.statusCode == 304 {
            throw NetworkError.notModified
        }

        guard response.statusCode == 200 else {
            throw NetworkError.status(response.statusCode)
        }

        do {
            let value = try JSONDecoder().decode(type, from: data)
            return ETagged(
                value: value,
                etag: response.value(forHTTPHeaderField: "ETag")
            )
        } catch {
            throw NetworkError.json(error)
        }
    }
}
