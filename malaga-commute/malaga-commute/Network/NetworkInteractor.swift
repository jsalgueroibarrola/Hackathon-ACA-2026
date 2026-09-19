//
//  NetworkInteractor.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//
import Foundation
import SwiftUI

protocol NetworkInteractor {}

extension NetworkInteractor {
    func getJSON<JSON>(request: URLRequest, type: JSON.Type)
        async throws(NetworkError) -> JSON where JSON: Decodable
    {
        let (data, response) = try await URLSession.shared.getData(for: request)
        guard response.statusCode == 200 else {
            throw NetworkError.status(response.statusCode)
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.json(error)
        }
    }

    func getStatus(request: URLRequest, status: Int = 200)
        async throws(NetworkError)
    {
        let (_, response) = try await URLSession.shared.getData(for: request)
        guard response.statusCode == status else {
            throw NetworkError.status(response.statusCode)
        }
    }
}
