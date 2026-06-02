//
//  MapCameraState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

struct MapCameraState: Sendable {
    var azimuth: Float
    var elevation: Float
    var distance: Float

    init() {
        azimuth = 0
        elevation = .pi / 4
        distance = 100
    }

    init(azimuth: Float, elevation: Float, distance: Float) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.distance = distance
    }
}
