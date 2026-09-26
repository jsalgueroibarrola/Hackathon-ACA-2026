import CoreLocation

/// Decoder for the Google encoded polyline format that ``Line/shape`` arrives in.
///
/// Each coordinate is stored as a pair of zig-zag signed deltas from the previous
/// one, split into five bit chunks, low chunk first, every chunk but the last
/// flagged with `0x20` and offset by 63 to land in printable ASCII.
///
/// Malformed input degrades to the prefix that could be read rather than trapping,
/// so a bad payload costs a missing overlay instead of a crash.
enum EncodedPolyline {

    static func decode(
        _ encoded: String,
        precision: Double = 1e5
    ) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        coordinates.reserveCapacity(encoded.utf8.count / 6)

        var latitude = 0
        var longitude = 0
        var bytes = encoded.utf8.makeIterator()

        func nextDelta() -> Int? {
            var result = 0
            var shift = 0
            while let byte = bytes.next() {
                let chunk = Int(byte) - 63
                guard chunk >= 0, shift < 32 else { return nil }
                result |= (chunk & 0x1F) << shift
                if chunk < 0x20 {
                    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
                }
                shift += 5
            }
            return nil
        }

        while let deltaLatitude = nextDelta() {
            guard let deltaLongitude = nextDelta() else { break }
            latitude += deltaLatitude
            longitude += deltaLongitude
            coordinates.append(
                CLLocationCoordinate2D(
                    latitude: Double(latitude) / precision,
                    longitude: Double(longitude) / precision
                )
            )
        }
        return coordinates
    }
}
