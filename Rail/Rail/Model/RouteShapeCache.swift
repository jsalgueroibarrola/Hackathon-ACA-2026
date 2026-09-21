//
//  RouteShapeCache.swift
//  Rail
//
//  Created by jakuru on 20/09/2026.
//

import CoreLocation
import Synchronization


struct RouteShape: Sendable, Hashable {
    let lineID: String
    let encoded: String
}


final class RouteShapeCache: Sendable {

    static let shared = RouteShapeCache()

    private struct Entry {
        let encoded: String
        let coordinates: [CLLocationCoordinate2D]
    }

    private let storage = Mutex<[String: Entry]>([:])

    /// Decoded coordinates for `shape`, decoding on the calling thread on a miss.
    ///
    /// A cached entry whose encoded string no longer matches is treated as a miss,
    /// so a payload that reroutes a line can never serve stale geometry.
    func coordinates(for shape: RouteShape) -> [CLLocationCoordinate2D] {
        let cached = storage.withLock { storage -> [CLLocationCoordinate2D]? in
            guard let entry = storage[shape.lineID],
                  entry.encoded == shape.encoded
            else { return nil }
            return entry.coordinates
        }
        if let cached { return cached }

        let decoded = EncodedPolyline.decode(shape.encoded)
        storage.withLock {
            $0[shape.lineID] = Entry(encoded: shape.encoded, coordinates: decoded)
        }
        return decoded
    }

    /// Decodes every shape that is not cached yet, spreading the work across cores.
    ///
    /// Marked `@concurrent` so the task group and its collection loop run off the
    /// main actor. Left inheriting the caller's isolation, every child result has
    /// to hop back to the main thread to be gathered, which measured roughly half
    /// the throughput.
    @concurrent
    func warm(_ shapes: [RouteShape]) async {
        let missing = storage.withLock { storage in
            shapes.filter { shape in
                guard let entry = storage[shape.lineID] else { return true }
                return entry.encoded != shape.encoded
            }
        }
        guard !missing.isEmpty else { return }

        let decoded = await withTaskGroup(of: (RouteShape, [CLLocationCoordinate2D]).self) { group in
            for shape in missing {
                group.addTask { (shape, EncodedPolyline.decode(shape.encoded)) }
            }

            var results: [(RouteShape, [CLLocationCoordinate2D])] = []
            results.reserveCapacity(missing.count)
            for await result in group {
                results.append(result)
            }
            return results
        }

        storage.withLock { storage in
            for (shape, coordinates) in decoded {
                storage[shape.lineID] = Entry(
                    encoded: shape.encoded,
                    coordinates: coordinates
                )
            }
        }
    }
}
