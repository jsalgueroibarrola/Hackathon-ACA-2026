//
//  ETagged.swift
//  Rail
//
//  Created by jakuru on 19/09/2026.
//

import Foundation

struct ETagged<Value: Sendable>: Sendable {
    let value: Value
    let etag: String?
}
