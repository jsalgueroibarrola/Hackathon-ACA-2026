#if DEBUG
    import WidgetKit

    extension NextTrainsWidgetEntry {
        fileprivate static func gallery(_ content: NextTrainsWidgetContent)
            -> NextTrainsWidgetEntry
        {
            NextTrainsWidgetEntry(
                date: .now,
                timeZone: .current,
                stationID: "54413",
                content: content
            )
        }

        fileprivate static let endOfService = gallery(
            .noService(
                station: "Málaga Centro Alameda",
                firstTomorrow: .now.addingTimeInterval(21_600)
            )
        )

        fileprivate static let expired = gallery(
            .noService(station: "Álora", firstTomorrow: nil)
        )
    }

    #Preview("1 · Con trenes · pequeño", as: .systemSmall) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.sample(at: .now, limit: 2)
    }

    #Preview("2 · Con trenes · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.sample(at: .now, limit: 3)
    }

    #Preview("3 · Con trenes · grande", as: .systemLarge) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.sample(at: .now, limit: 7)
    }

    #Preview("4 · Con trenes · bloqueo", as: .accessoryRectangular) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.sample(at: .now, limit: 2)
    }

    #Preview("5 · Sin configurar · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.gallery(.unconfigured)
    }

    #Preview("6 · Sin configurar · pequeño", as: .systemSmall) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.gallery(.unconfigured)
    }

    #Preview("7 · Sin horarios · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.gallery(.dataMissing)
    }

    #Preview("8 · Estación no disponible · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.gallery(.unknownStation)
    }

    #Preview("9 · Fin de servicio · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.endOfService
    }

    #Preview("10 · Fin de servicio · pequeño", as: .systemSmall) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.endOfService
    }

    #Preview("11 · Horarios caducados · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.expired
    }

    #Preview("12 · Marcador de posición · mediano", as: .systemMedium) {
        NextTrainsWidget()
    } timeline: {
        NextTrainsWidgetEntry.sample(at: .now, limit: 3)
    }
#endif
