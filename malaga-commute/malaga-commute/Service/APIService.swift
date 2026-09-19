//
//  APIService.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

protocol APIService: Sendable {

    func getNetwork() async -> APIResponse<NetworkResponseDTO>
}

@APIActor
struct APIServiceImpl: APIService, NetworkInteractor {
    func getNetwork() async -> APIResponse<NetworkResponseDTO> {
        return await .call {
            let req = URLRequest.request(url: .network)
            return try await getJSON(
                request: req,
                type: NetworkResponseDTO.self
            )
        }
    }

    func getTimetable() async -> APIResponse<TimetableResponseDTO> {
        return await .call {
            let req = URLRequest.request(url: .timetable)
            return try await getJSON(
                request: req,
                type: TimetableResponseDTO.self
            )
        }
    }
}
