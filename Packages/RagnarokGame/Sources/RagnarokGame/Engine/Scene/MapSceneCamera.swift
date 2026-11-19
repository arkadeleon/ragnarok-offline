//
//  MapSceneCamera.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation
import simd

/// Decaying back-and-forth world-space camera shake offset.
struct CameraShake: Sendable {
    private var amplitude: Float = 0
    private var duration: TimeInterval = 0
    private var frequency: Float = 35
    private var elapsedTime: TimeInterval = 0

    private(set) var offset: SIMD3<Float> = .zero

    var isActive: Bool {
        amplitude > 0 && duration > 0 && elapsedTime < duration
    }

    mutating func trigger(amplitude: Float, duration: TimeInterval, frequency: Float = 35) {
        guard amplitude > 0, duration > 0 else {
            return
        }

        let currentRemainingAmplitude: Float = if isActive {
            self.amplitude * Float(1 - elapsedTime / self.duration)
        } else {
            0
        }

        guard amplitude >= currentRemainingAmplitude else {
            return
        }

        self.amplitude = amplitude
        self.duration = duration
        self.frequency = frequency
        self.elapsedTime = 0
        self.offset = .zero
    }

    mutating func update(deltaTime: TimeInterval) {
        guard isActive, deltaTime >= 0 else {
            if offset != .zero || amplitude > 0 || duration > 0 {
                reset()
            }
            return
        }

        elapsedTime += deltaTime
        guard elapsedTime < duration else {
            reset()
            return
        }

        let progress = Float(elapsedTime / duration)
        let decay = 1 - progress
        let angle = Float(elapsedTime) * frequency
        offset = SIMD3<Float>(sin(angle), cos(angle * 1.3), sin(angle * 0.7)) * (amplitude * decay)
    }

    mutating func reset() {
        amplitude = 0
        duration = 0
        elapsedTime = 0
        offset = .zero
    }
}

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

    var shakeOffset: SIMD3<Float> {
        cameraShake.offset
    }

    private var cameraShake = CameraShake()
    private var lastPlayerPosition: SIMD3<Float>?
    private var lastUpdateTime: TimeInterval?

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

    mutating func update(playerPosition: SIMD3<Float>, atTime time: TimeInterval) {
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

        let deltaTime = time - lastUpdateTime
        guard deltaTime >= 0, deltaTime < 0.5,
              simd_distance(lastPlayerPosition, playerPosition) < 8 else {
            currentState.target = playerPosition
            currentState.azimuth = desiredState.azimuth
            currentState.elevation = desiredState.elevation
            currentState.distance = desiredState.distance
            cameraShake.reset()
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

        cameraShake.update(deltaTime: deltaTime)
    }

    mutating func shake(amplitude: Float, duration: TimeInterval, frequency: Float = 35) {
        cameraShake.trigger(amplitude: amplitude, duration: duration, frequency: frequency)
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
        cameraShake.reset()
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
