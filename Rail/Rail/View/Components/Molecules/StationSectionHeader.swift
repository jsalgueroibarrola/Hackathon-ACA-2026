import SwiftUI

struct StationSectionHeader: View {
    private let title: LocalizedStringResource

    private static let minHeight: CGFloat = 32

    init(_ title: LocalizedStringResource) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.captionEmphasized)
            .tracking(Tracking.wide)
            .textCase(.uppercase)
            .foregroundStyle(.textSecondary)
            .frame(maxWidth: .infinity, minHeight: Self.minHeight, alignment: .leading)
            .padding(.bottom, Spacing.md)
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: ScreenLayout.margin * 2,
                    bottom: 0,
                    trailing: ScreenLayout.margin
                )
            )
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    List {
        Section {
            Text(verbatim: "Málaga Centro-Alameda")
        } header: {
            StationSectionHeader("Línea C-1")
        }
    }
    .listStyle(.plain)
}
