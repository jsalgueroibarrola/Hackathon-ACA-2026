import Foundation

enum FavoritesCapacity {
    static let minimumVisible = 3
    static let maximumVisible = 12

    static func candidateCounts(total: Int) -> [Int] {
        let highest = min(total, maximumVisible)
        let lowest = min(total, minimumVisible)
        return Array(stride(from: highest, through: lowest, by: -1))
    }
}
