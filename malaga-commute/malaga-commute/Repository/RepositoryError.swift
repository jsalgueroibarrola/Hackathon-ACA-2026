//
//  RepositoryError.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

enum RepositoryError: LocalizedError {
    case missingNetwork
    case invalidDay(String)

    var errorDescription: String? {
        switch self {
        case .missingNetwork: "No network data stored"
        case .invalidDay(let value): "Invalid day format: \(value)"
        }
    }
}
