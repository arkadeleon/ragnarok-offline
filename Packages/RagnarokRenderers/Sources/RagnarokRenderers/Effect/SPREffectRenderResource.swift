//
//  SPREffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/2.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class SPREffectRenderResource {
    public let definition: SPREffectDefinition
    public let vertices: [SPREffectVertex]
    public let textures: [any MTLTexture]
    public let frameInterval: TimeInterval
    public let frameSize: SIMD2<Float>

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: SPREffectAsset) {
        self.definition = asset.definition
        self.vertices = [
            SPREffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            SPREffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            SPREffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            SPREffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            SPREffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            SPREffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.textures = asset.frameImages.enumerated().compactMap { index, frameImage in
            MetalTextureFactory.makeTexture(from: frameImage, device: device, label: "sprEffect[\(index)]")
        }
        self.frameInterval = max(asset.frameInterval, 1 / 60)
        self.frameSize = [
            Float(asset.frameSize.width),
            Float(asset.frameSize.height),
        ]
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        if definition.stopsAtEnd {
            return false
        }

        guard elapsedTime >= 0 else {
            return false
        }

        if let duration = definition.duration {
            return elapsedTime >= duration
        }

        if definition.repeats {
            return false
        }

        return elapsedTime >= TimeInterval(textures.count) * frameInterval
    }

    func renderWorldPosition(_ worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        var basePosition = worldPosition
        if definition.rendersAtHead {
            basePosition.y += 2.5
        }

        return basePosition + [definition.spriteOffset.x / 35, -definition.spriteOffset.y / 35, 0]
    }

    func texture(elapsedTime: TimeInterval) -> (any MTLTexture)? {
        guard !textures.isEmpty else {
            return nil
        }

        guard elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            let frameIndex = Int(elapsedTime / frameInterval) % textures.count
            return textures[frameIndex]
        } else {
            let frameIndex = min(Int(elapsedTime / frameInterval), textures.count - 1)
            return textures[frameIndex]
        }
    }
}
