import Foundation

extension LocalizedStringResource {
    static func distanceAway(_ label: String) -> Self {
        LocalizedStringResource(
            "A \(label)",
            comment:
                "Distancia desde la ubicación del usuario hasta una estación, por ejemplo «A 1,2 km». Se usa en la tarjeta de próximos trenes y en las filas de estaciones."
        )
    }
}
