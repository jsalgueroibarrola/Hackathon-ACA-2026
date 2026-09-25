import Foundation

struct AlertsResponseDTO: Decodable, Sendable {
    let ts: Int?
    let alerts: [ServiceAlertDTO]
}

struct ServiceAlertDTO: Decodable, Sendable {
    let id: String
    let kind: AlertKindDTO
    let lines: [String]
    let since: Int?
    let until: Int?
    let text: String
}

enum AlertKindDTO: String, Decodable, Sendable {
    case notice
    case info
    case other

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = AlertKindDTO(rawValue: try container.decode(String.self)) ?? .other
    }
}
