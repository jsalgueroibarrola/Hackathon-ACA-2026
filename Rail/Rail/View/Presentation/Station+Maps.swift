import MapKit

extension Station {
    @MainActor
    func openDirections(_ mode: TravelMode? = nil) {
        let item = MKMapItem(
            location: CLLocation(latitude: latitude, longitude: longitude),
            address: nil
        )
        item.name = name
        item.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: mode?.launchMode ?? MKLaunchOptionsDirectionsModeDefault
            ]
        )
    }
}

extension TravelMode {
    fileprivate var launchMode: String {
        switch self {
        case .walking: MKLaunchOptionsDirectionsModeWalking
        case .cycling: MKLaunchOptionsDirectionsModeCycling
        case .automobile: MKLaunchOptionsDirectionsModeDriving
        case .transit: MKLaunchOptionsDirectionsModeTransit
        }
    }
}
