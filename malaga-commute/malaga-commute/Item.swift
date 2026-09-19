//
//  Item.swift
//  malaga-commute
//
//  Created by jakuru on 19/09/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
