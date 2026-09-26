import SwiftUI

struct DataUnavailableView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                LocalizedStringResource(
                    "No hay horarios disponibles",
                    comment: "Título del estado vacío cuando no se ha podido descargar ningún dato y no hay nada guardado."
                ),
                systemImage: "wifi.exclamationmark"
            )
        } description: {
            Text(message)
        } actions: {
            Button(
                LocalizedStringResource(
                    "Reintentar",
                    comment: "Botón para volver a intentar una descarga que ha fallado."
                ),
                action: retry
            )
                .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
#Preview {
    DataUnavailableView(message: "No hay conexión a internet. Comprueba la conexión e inténtalo de nuevo.") {}
}
#endif
