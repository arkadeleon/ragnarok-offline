//
//  WorldLighting.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/2/10.
//

import Foundation
import RagnarokFileFormats

public struct WorldLighting: Sendable {
    public static let preview = WorldLighting(
        longitude: 45,
        latitude: 45,
        diffuse: SIMD3<Float>(repeating: 1),
        ambient: SIMD3<Float>(repeating: 0.3),
        opacity: 1,
    )

    public var direction: SIMD3<Float>
    public var diffuse: SIMD3<Float>
    public var ambient: SIMD3<Float>
    public var opacity: Float

    public init(
        longitude: Float,
        latitude: Float,
        diffuse: SIMD3<Float>,
        ambient: SIMD3<Float>,
        opacity: Float
    ) {
        let longitudeRadians = longitude * .pi / 180
        let latitudeRadians = latitude * .pi / 180
        self.direction = SIMD3<Float>(
            Float(cos(longitudeRadians) * sin(latitudeRadians)),
            Float(cos(latitudeRadians)),
            Float(sin(longitudeRadians) * sin(latitudeRadians))
        )
        self.diffuse = diffuse
        self.ambient = ambient
        self.opacity = opacity
    }

    public init(light: RSW.Light) {
        self.init(
            longitude: Float(light.longitude),
            latitude: Float(light.latitude),
            diffuse: SIMD3<Float>(light.diffuseRed, light.diffuseGreen, light.diffuseBlue),
            ambient: SIMD3<Float>(light.ambientRed, light.ambientGreen, light.ambientBlue),
            opacity: light.opacity
        )
    }
}
