import SwiftUI

struct DepartedToggleRow: View {
    private let count: Int
    private let isExpanded: Bool
    private let action: () -> Void

    init(count: Int, isExpanded: Bool, action: @escaping () -> Void) {
        self.count = count
        self.isExpanded = isExpanded
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(.textTertiary)
                Text(
                    isExpanded
                        ? LocalizedStringResource(
                            "Ocultar salidas anteriores",
                            comment: "Horarios: botón que oculta los trenes que ya han salido hoy."
                        )
                        : LocalizedStringResource(
                            "Ver \(count) salidas anteriores",
                            comment: "Horarios: botón que muestra los trenes que ya han salido hoy; el número es cuántos."
                        )
                )
                .foregroundStyle(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .font(.subheadline)
            .padding(.horizontal, ScreenLayout.margin)
            .frame(minHeight: Size.rowMin)
            .background(.bgSecondary)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
}

#if DEBUG
#Preview {
    List {
        DepartedToggleRow(count: 12, isExpanded: false) {}
        DepartedToggleRow(count: 1, isExpanded: false) {}
        DepartedToggleRow(count: 12, isExpanded: true) {}
    }
    .listStyle(.plain)
}
#endif
