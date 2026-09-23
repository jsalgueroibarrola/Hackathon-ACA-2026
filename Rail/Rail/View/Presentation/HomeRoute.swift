import SwiftUI

enum HomeRoute: Hashable {
    case favorites
    case station(id: String)
}

extension HomeRoute {
    static func reordered(_ ids: [String], from source: IndexSet, to destination: Int) -> [String] {
        var reordered = ids
        reordered.move(fromOffsets: source, toOffset: destination)
        return reordered
    }
}
