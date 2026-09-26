import SwiftData

enum RailStore {
    static let appGroup = "group.com.JadeHorizonStudio.Rail"

    static var schema: Schema { Schema(RailSchema.models) }

    static func configuration(allowsSave: Bool = true) -> ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            allowsSave: allowsSave,
            groupContainer: .identifier(appGroup)
        )
    }
}
