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
    struct State: Sendable {
        var azimuth: Float
        var elevation: Float
        var distance: Float
        var target: SIMD3<Float>?
    }

    private static let dampingRate: Double = 6.32
    private static let minimumElevation: Float = .pi / 12
    private static let maximumElevation: Float = .pi / 3
    private static let minimumDistance: Float = 3
    private static let maximumDistance: Float = 120

    var isFixedCamera = false

    private(set) var desiredState: MapSceneCamera.State
    private(set) var currentState: MapSceneCamera.State

    var azimuth: Float {
        get {
            currentState.azimuth
        }
        set {
            guard !isFixedCamera else {
                return
            }
            let wrappedValue = Self.wrapAngle(newValue)
            desiredState.azimuth = wrappedValue
            currentState.azimuth = wrappedValue
        }
    }

    var elevation: Float {
        get {
            currentState.elevation
        }
        set {
            guard !isFixedCamera else {
                return
            }
            let clampedValue = simd_clamp(newValue, Self.minimumElevation, Self.maximumElevation)
            desiredState.elevation = clampedValue
            currentState.elevation = clampedValue
        }
    }

    var distance: Float {
        get {
            currentState.distance
        }
        set {
            guard !isFixedCamera else {
                return
            }
            let clampedValue = simd_clamp(newValue, Self.minimumDistance, Self.maximumDistance)
            desiredState.distance = clampedValue
            currentState.distance = clampedValue
        }
    }

    var target: SIMD3<Float>? {
        currentState.target
    }

    private var lastPlayerPosition: SIMD3<Float>?
    private var lastUpdateTime: ContinuousClock.Instant?

    init() {
        #if os(visionOS)
        let initialState = MapSceneCamera.State(azimuth: 0, elevation: .pi / 6, distance: 15, target: nil)
        #else
        let initialState = MapSceneCamera.State(azimuth: 0, elevation: .pi / 4, distance: 100, target: nil)
        #endif
        desiredState = initialState
        currentState = initialState
    }

    init(azimuth: Float, elevation: Float, distance: Float) {
        let initialState = MapSceneCamera.State(
            azimuth: Self.wrapAngle(azimuth),
            elevation: simd_clamp(elevation, Self.minimumElevation, Self.maximumElevation),
            distance: simd_clamp(distance, Self.minimumDistance, Self.maximumDistance),
            target: nil
        )
        desiredState = initialState
        currentState = initialState
    }

    mutating func update(playerPosition: SIMD3<Float>, at time: ContinuousClock.Instant) {
        defer {
            lastPlayerPosition = playerPosition
            lastUpdateTime = time
        }

        desiredState.target = playerPosition

        guard let currentTarget = currentState.target, let lastPlayerPosition, let lastUpdateTime else {
            currentState.target = playerPosition
            currentState.azimuth = desiredState.azimuth
            currentState.elevation = desiredState.elevation
            currentState.distance = desiredState.distance
            return
        }

        let deltaTime = lastUpdateTime.duration(to: time).timeInterval
        guard deltaTime >= 0, deltaTime < 0.5,
              simd_distance(lastPlayerPosition, playerPosition) < 8 else {
            currentState.target = playerPosition
            currentState.azimuth = desiredState.azimuth
            currentState.elevation = desiredState.elevation
            currentState.distance = desiredState.distance
            return
        }

        let fraction = Float(-expm1(-Self.dampingRate * deltaTime))
        currentState.target = currentTarget + (playerPosition - currentTarget) * fraction

        if !isFixedCamera {
            let azimuthDelta = Self.wrapAngle(desiredState.azimuth - currentState.azimuth)
            currentState.azimuth = Self.wrapAngle(currentState.azimuth + azimuthDelta * fraction)
            currentState.elevation += (desiredState.elevation - currentState.elevation) * fraction
            currentState.distance += (desiredState.distance - currentState.distance) * fraction
        }
    }

    mutating func animate(azimuth: Float? = nil, elevation: Float? = nil, distance: Float? = nil) {
        guard !isFixedCamera else {
            return
        }
        if let azimuth {
            desiredState.azimuth = Self.wrapAngle(azimuth)
        }
        if let elevation {
            desiredState.elevation = simd_clamp(elevation, Self.minimumElevation, Self.maximumElevation)
        }
        if let distance {
            desiredState.distance = simd_clamp(distance, Self.minimumDistance, Self.maximumDistance)
        }
    }

    mutating func reset() {
        desiredState.target = nil
        currentState.target = nil
        lastPlayerPosition = nil
        lastUpdateTime = nil
    }

    /// Wraps an angle into `[-π, π)` for shortest-arc interpolation.
    private static func wrapAngle(_ angle: Float) -> Float {
        var wrappedAngle = (angle + .pi).truncatingRemainder(dividingBy: .pi * 2)
        if wrappedAngle < 0 {
            wrappedAngle += .pi * 2
        }
        return wrappedAngle - .pi
    }
}
