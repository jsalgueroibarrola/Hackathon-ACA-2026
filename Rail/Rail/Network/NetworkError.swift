//
//  NetworkError.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case transport(Error)
    case general(Error)
    case status(Int)
    case dataNotValid
    case nonHTTP
    case json(Error)
    case notModified
    case cancelled

    var errorDescription: String? {
        switch self {
        case .transport(let error):
            "Transport error: \(error.localizedDescription)"
        case .general(let error): "General error: \(error.localizedDescription)"
        case .status(let code): "Status error: \(code)"
        case .dataNotValid: "Data not valid"
        case .nonHTTP: "Not an HTTP connection"
        case .json(let error): "JSON error: \(error)"
        case .notModified: "Resource not modified"
        case .cancelled: "Request cancelled"
        }
    }
}
