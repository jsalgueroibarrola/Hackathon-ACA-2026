import AppIntents

struct SelectFavoriteStationIntent: WidgetConfigurationIntent {
    static let title = LocalizedStringResource(
        "Estación",
        comment: "Título del intent de configuración del widget"
    )

    static let description = IntentDescription(
        LocalizedStringResource(
            "Muestra los próximos trenes de la estación que elijas.",
            comment: "Descripción del intent de configuración del widget"
        )
    )

    @Parameter(
        title: LocalizedStringResource(
            "Estación",
            comment: "Etiqueta del selector de estación en la configuración del widget"
        )
    )
    var station: StationEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Próximos trenes en \(\.$station)")
    }
}
