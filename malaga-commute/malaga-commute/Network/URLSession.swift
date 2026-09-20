//
//  URLSession.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

extension URLSession {

    func getData(for request: URLRequest) async throws(NetworkError) -> (
        data: Data, response: HTTPURLResponse
    ) {
        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, response)
        } catch let error as NetworkError {
            throw error
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.general(error)
        }
    }
}
