//
//  APIService.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

protocol APIService: Sendable {
    func getNetwork(etag: String?) async -> APIResponse<
        ETagged<NetworkResponseDTO>
    >
    func getTimetable(etag: String?) async -> APIResponse<
        ETagged<TimetableResponseDTO>
    >
}

struct APIServiceImpl: APIService, NetworkInteractor {

    func getNetwork(etag: String?) async -> APIResponse<
        ETagged<NetworkResponseDTO>
    > {
        await .call {
            let request = URLRequest.request(url: .network, etag: etag)
            return try await getJSON(
                request: request,
                type: NetworkResponseDTO.self
            )
        }
    }

    func getTimetable(etag: String?) async -> APIResponse<
        ETagged<TimetableResponseDTO>
    > {
        await .call {
            let request = URLRequest.request(
                url: .timetable,
                etag: etag,
                timeout: 60
            )
            return try await getJSON(
                request: request,
                type: TimetableResponseDTO.self
            )
        }
    }
}
