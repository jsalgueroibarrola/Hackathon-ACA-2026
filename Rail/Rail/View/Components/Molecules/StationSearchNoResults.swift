import SwiftUI

struct StationSearchNoResults: View {
    private let query: String

    init(_ query: String) {
        self.query = query
    }

    var body: some View {
        IllustratedMessage(
            LocalizedStringResource(
                "Sin resultados para «\(query)»",
                comment: "Selector de estación y pantalla Estaciones: título cuando la búsqueda no encuentra ninguna estación; incluye el texto buscado."
            ),
            message: LocalizedStringResource(
                "Revisa la ortografía o busca por línea.",
                comment: "Selector de estación y pantalla Estaciones: sugerencia cuando la búsqueda no encuentra ninguna estación."
            ),
            illustration: .noResults,
            prominence: .large
        )
    }
}

#if DEBUG
#Preview {
    StationSearchNoResults("Sevilla")
        .background(.bgSecondary)
}
#endif
