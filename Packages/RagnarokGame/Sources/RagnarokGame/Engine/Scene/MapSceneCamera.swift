//
//  MapSceneCamera.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation
import simd

/// The scene's camera settings and its smoothed focus in map world coordinates.
struct MapSceneCamera: Sendable {
    var azimuth: Float
    var elevation: Float
    var distance: Float

    private(set) var target: SIMD3<Float>?

    private let followSpeed: Double = 6

    private var lastPlayerPosition: SIMD3<Float>?
    private var lastUpdateTime: ContinuousClock.Instant?

    init() {
        azimuth = 0
        #if os(visionOS)
        elevation = .pi / 6
        distance = 15
        #else
        elevation = .pi / 4
        distance = 100
        #endif
    }

    init(azimuth: Float, elevation: Float, distance: Float) {
        self.azimuth = azimuth
        self.elevation = elevation
        self.distance = distance
    }

    mutating func update(playerPosition: SIMD3<Float>, at time: ContinuousClock.Instant) {
        defer {
            lastPlayerPosition = playerPosition
            lastUpdateTime = time
        }

        guard let target, let lastPlayerPosition, let lastUpdateTime else {
            self.target = playerPosition
            return
        }

        let deltaTime = lastUpdateTime.duration(to: time).timeInterval
        guard deltaTime >= 0, deltaTime < 0.5,
              simd_distance(lastPlayerPosition, playerPosition) < 8 else {
            self.target = playerPosition
            return
        }

        let fraction = Float(-expm1(-followSpeed * deltaTime))
        self.target = target + (playerPosition - target) * fraction
    }

    mutating func reset() {
        target = nil
        lastPlayerPosition = nil
        lastUpdateTime = nil
    }
}
