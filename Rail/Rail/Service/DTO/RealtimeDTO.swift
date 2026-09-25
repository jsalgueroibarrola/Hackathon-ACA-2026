import Foundation

struct RealtimeResponseDTO: Decodable, Sendable {
    let ts: Int?
    let partial: Bool?
    let trains: [LiveTrainDTO]
}

struct LiveTrainDTO: Decodable, Sendable {
    let line: String
    let train: String
    let serviceDay: String?
    let delay: Int?
    let status: LiveStatusDTO
    let stop: String?
    let next: String?
    let lat: Double?
    let lon: Double?
    let platform: String?
    let at: Int?
}

enum LiveStatusDTO: String, Decodable, Sendable {
    case at
    case left
    case approaching
    case unknown

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = LiveStatusDTO(rawValue: try container.decode(String.self)) ?? .unknown
    }
}
