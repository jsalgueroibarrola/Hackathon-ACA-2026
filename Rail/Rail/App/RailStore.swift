//
//  RailStore.swift
//  Rail
//
//  Created by jakuru on 24/09/2026.
//

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
