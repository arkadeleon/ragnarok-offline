//
//  GroundLighting.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/2/10.
//

import RagnarokFileFormats

public struct GroundLighting: Sendable {
    public static let preview = GroundLighting(
        ambient: SIMD3<Float>(repeating: 1),
        diffuse: SIMD3<Float>(repeating: 0),
        opacity: 1
    )

    public var ambient: SIMD3<Float>
    public var diffuse: SIMD3<Float>
    public var opacity: Float

    public init(ambient: SIMD3<Float>, diffuse: SIMD3<Float>, opacity: Float) {
        self.ambient = ambient
        self.diffuse = diffuse
        self.opacity = opacity
    }

    public init(light: RSW.Light) {
        ambient = SIMD3<Float>(light.ambientRed, light.ambientGreen, light.ambientBlue)
        diffuse = SIMD3<Float>(light.diffuseRed, light.diffuseGreen, light.diffuseBlue)
        opacity = light.opacity
    }
}
