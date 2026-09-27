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

extension Measurement<UnitLength> {
    var distanceLabel: String {
        let meters = converted(to: .meters).value
        return meters < 1000
            ? Measurement(value: meters.rounded(), unit: UnitLength.meters)
                .formatted(
                    .measurement(width: .abbreviated, usage: .asProvided)
                )
            : converted(to: .kilometers)
                .formatted(
                    .measurement(
                        width: .abbreviated,
                        usage: .asProvided,
                        numberFormatStyle: .number.precision(.fractionLength(1))
                    )
                )
    }
}
