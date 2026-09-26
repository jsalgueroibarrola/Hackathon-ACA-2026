import Foundation
import SwiftData

extension ModelContext {
    func first<T: PersistentModel>(_ type: T.Type) throws -> T? {
        var descriptor = FetchDescriptor<T>()
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }

    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        try fetch(FetchDescriptor<T>()).forEach { delete($0) }
    }

    func insertAll(_ models: [any PersistentModel]) {
        models.forEach { insert($0) }
    }

    func commit(_ changes: () throws -> Void) throws {
        do {
            try changes()
            try save()
        } catch {
            rollback()
            throw error
        }
    }
}

extension Collection where Index == Int {
    func chunks(of size: Int) -> [SubSequence] {
        precondition(size > 0)
        return stride(from: startIndex, to: endIndex, by: size).map { start in
            self[start..<Swift.min(start + size, endIndex)]
        }
    }
}
