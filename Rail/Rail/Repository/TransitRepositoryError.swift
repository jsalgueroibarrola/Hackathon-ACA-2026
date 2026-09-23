import Foundation

enum TransitRepositoryError: LocalizedError {
    case missingNetwork
    case invalidDay(String)

    var errorDescription: String? {
        switch self {
        case .missingNetwork: "No network data stored"
        case .invalidDay(let value): "Invalid day format: \(value)"
        }
    }
}
