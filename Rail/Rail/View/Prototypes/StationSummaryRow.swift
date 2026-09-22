import SwiftUI

struct StationSummaryRow: View {
    let station: Station
    var distance: Measurement<UnitLength>?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(station.name)
                    .font(.headline)
                Text(lineLabel)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }

            if let distance {
                Spacer(minLength: Spacing.sm)
                Text(distance.distanceLabel)
                    .font(.subheadlineEmphasized)
                    .monospacedDigit()
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    private var lineLabel: String {
        station.lines.map(\.id).sorted().joined(separator: " · ")
    }
}

// MARK: - Previews

#Preview("Estados") {
    let station = Station(
        id: "54413",
        name: "Málaga-Centro Alameda",
        latitude: 36.717,
        longitude: -4.425,
        isAccessible: true
    )

    List {
        StationSummaryRow(station: station)
        StationSummaryRow(
            station: station,
            distance: Measurement(value: 420, unit: .meters)
        )
        StationSummaryRow(
            station: station,
            distance: Measurement(value: 8_400, unit: .meters)
        )
    }
}

#Preview("Dynamic Type") {
    let station = Station(
        id: "54413",
        name: "Universidad de Málaga – Andalucía Tech",
        latitude: 36.7154,
        longitude: -4.4790
    )

    List {
        StationSummaryRow(
            station: station,
            distance: Measurement(value: 1_250, unit: .meters)
        )
    }
    .environment(\.dynamicTypeSize, .accessibility2)
}
