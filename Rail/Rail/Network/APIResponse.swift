//
//  APIResponse.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

enum APIResponse<T: Sendable>: Sendable {
    case success(T)
    case notModified(CacheFreshness)
    case failure(NetworkError)
}

extension APIResponse {

    static func call(
        _ block: @Sendable () async throws -> T
    ) async -> APIResponse<T> {
        do {
            let value = try await block()
            return .success(value)
        } catch NetworkError.notModified(let freshness) {
            return .notModified(freshness)
        } catch let error as NetworkError {
            return .failure(error)
        } catch is CancellationError {
            return .failure(.cancelled)
        } catch let error as URLError where error.code == .cancelled {
            return .failure(.cancelled)
        } catch let error as URLError {
            return .failure(.transport(error))
        } catch {
            return .failure(.general(error))
        }
    }

    func payload() throws(NetworkError) -> T? {
        switch self {
        case .success(let value): return value
        case .notModified: return nil
        case .failure(let error): throw error
        }
    }
}
