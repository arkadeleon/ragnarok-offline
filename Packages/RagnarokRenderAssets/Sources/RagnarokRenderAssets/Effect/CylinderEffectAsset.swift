//
//  CylinderEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects
import RagnarokResources

public struct CylinderEffectAsset: Sendable {
    public let definition: CylinderEffectDefinition
    public let rotationDegrees: SIMD3<Float>
    public let textureImage: CGImage

    static func load(with definition: CylinderEffectDefinition, using resourceManager: ResourceManager) async throws -> CylinderEffectAsset {
        var rotationDegrees = definition.rotationDegrees
        if let range = definition.rotationXRandomRange {
            rotationDegrees.x += Float.random(in: range)
        }
        if let range = definition.rotationYRandomRange {
            rotationDegrees.y += Float.random(in: range)
        }
        if let range = definition.rotationZRandomRange {
            rotationDegrees.z += Float.random(in: range)
        }

        let texturePath = ResourcePath.effectDirectory
            .appending(definition.textureName)
            .appendingPathExtension("tga")
        let image = try await resourceManager.image(at: texturePath)

        let asset = CylinderEffectAsset(
            definition: definition,
            rotationDegrees: rotationDegrees,
            textureImage: image.cgImage
        )
        return asset
    }
}
