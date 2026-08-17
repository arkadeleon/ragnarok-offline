//
//  Fog.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/16.
//

import simd

public struct Fog: Sendable {
    public static let disabled = Fog()

    public var isEnabled = false

    /// How far from the camera the fog starts, in world units.
    public var near: Float = 0

    /// How far from the camera the fog reaches its full strength, in world units.
    public var far: Float = 0

    public var color = SIMD3<Float>()

    private init() {}

    /// Creates the fog from the distances a map states as fractions.
    public init(near: Float, far: Float, color: SIMD3<Float>) {
        // The fractions need a scale to become world units. This one keeps the map
        // readable at the far end of the camera's zoom range, where everything would
        // otherwise sink into the fog color.
        let distanceScale: Float = 360

        self.isEnabled = true
        self.near = near * distanceScale
        self.far = far * distanceScale
        self.color = color
    }
}
