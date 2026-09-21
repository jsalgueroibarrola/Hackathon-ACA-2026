//
//  LineOverlay.swift
//  malaga-commute
//
//  Created by jakuru on 21/09/2026.
//

import MapKit
import SwiftUI

struct LineOverlay: Identifiable {
    let id: String
    let name: String
    let colorHex: String
    let coordinates: [CLLocationCoordinate2D]

    init(
        id: String,
        name: String,
        colorHex: String,
        coordinates: [CLLocationCoordinate2D]
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.coordinates = coordinates
    }

    init(line: Line, coordinates: [CLLocationCoordinate2D]) {
        self.id = line.id
        self.name = line.name
        self.colorHex = line.colorHex
        self.coordinates = coordinates
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
