import MapKit

enum MapCameraBuilder {
    static let framingInset = 0.15
    static let stationSpan: CLLocationDistance = 1_800

    static func networkRect(
        _ coordinates: [CLLocationCoordinate2D],
        inset: Double = framingInset
    ) -> MKMapRect? {
        guard !coordinates.isEmpty else { return nil }
        let rect =
            coordinates
            .map(MKMapPoint.init)
            .reduce(MKMapRect.null) {
                $0.union(
                    MKMapRect(origin: $1, size: MKMapSize(width: 0, height: 0))
                )
            }
        return rect.insetBy(dx: -rect.width * inset, dy: -rect.height * inset)
    }

    static func region(
        focusing coordinate: CLLocationCoordinate2D,
        span: CLLocationDistance = stationSpan,
        lift: Double = 0
    ) -> MKCoordinateRegion {
        let point = MKMapPoint(coordinate)
        let offset =
            span * lift * MKMapPointsPerMeterAtLatitude(coordinate.latitude)
        return MKCoordinateRegion(
            center: MKMapPoint(x: point.x, y: point.y + offset).coordinate,
            latitudinalMeters: span,
            longitudinalMeters: span
        )
    }

    static func lift(covering: CGFloat, reserved: CGFloat, viewport: CGSize) -> Double {
        let side = min(viewport.width, viewport.height)
        guard side > 0 else { return 0 }
        return max(0, covering - reserved) / 2 / side
    }
}
