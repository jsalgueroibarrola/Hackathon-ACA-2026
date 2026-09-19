//
//  APIResponse.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

enum APIResponse<T: Sendable>: Sendable {
    case success(T)
    case failure(NetworkError)
}

extension APIResponse {

    /// Runs a networking operation and wraps its outcome, so callers consume the
    /// result without handling `try` themselves.
    static func call(
        _ block: @Sendable () async throws -> T
    ) async -> APIResponse<T> {
        do {
            let value = try await block()
            return .success(value)
        } catch let error as NetworkError {
            return .failure(error)
        } catch let error as URLError {
            return .failure(.transport(error))
        } catch {
            return .failure(.general(error))
        }
    }
}
