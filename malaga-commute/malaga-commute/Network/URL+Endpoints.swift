//
//  URL+Endpoints.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//
import Foundation

private let apiBaseURL: URL = URL(
    string: "https://n5urg1b4g0.execute-api.eu-west-3.amazonaws.com"
)!

private let apiMalagaURL: URL = apiBaseURL.appending(path: "malaga")

extension URL {
    static let network: URL =
        apiMalagaURL.appending(path: "network.json")

    static let timetable: URL =
        apiMalagaURL.appending(path: "timetable.json")

}
