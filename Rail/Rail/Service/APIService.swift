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
    func getAlerts(etag: String?) async -> APIResponse<
        ETagged<AlertsResponseDTO>
    >
    func getRealtime(etag: String?) async -> APIResponse<
        ETagged<RealtimeResponseDTO>
    >
}

struct APIServiceImpl: APIService, NetworkInteractor {

    func getNetwork(etag: String?) async -> APIResponse<
        ETagged<NetworkResponseDTO>
    > {
        await get(.network, etag: etag)
    }

    func getTimetable(etag: String?) async -> APIResponse<
        ETagged<TimetableResponseDTO>
    > {
        await get(.timetable, etag: etag)
    }

    func getAlerts(etag: String?) async -> APIResponse<
        ETagged<AlertsResponseDTO>
    > {
        await get(.alerts, etag: etag)
    }

    func getRealtime(etag: String?) async -> APIResponse<
        ETagged<RealtimeResponseDTO>
    > {
        await get(.realtime, etag: etag)
    }

    private func get<JSON: Decodable & Sendable>(
        _ url: URL,
        etag: String?
    ) async -> APIResponse<ETagged<JSON>> {
        await .call {
            try await getJSON(
                request: .request(url: url, etag: etag),
                type: JSON.self
            )
        }
    }
}
