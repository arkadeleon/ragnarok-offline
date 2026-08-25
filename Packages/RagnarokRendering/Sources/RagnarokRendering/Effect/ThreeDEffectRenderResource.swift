//
//  ThreeDEffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/29.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class ThreeDEffectRenderResource {
    public let animation: ThreeDEffectAnimation
    public let vertices: [ThreeDEffectVertex]
    public let textures: [(any MTLTexture)?]

    public var definition: ThreeDEffectDefinition {
        animation.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, effect: ThreeDEffect, instance: ThreeDEffect.Instance, asset: ThreeDEffectAsset) {
        self.animation = ThreeDEffectAnimation(effect: effect, instance: instance, asset: asset)
        self.vertices = [
            ThreeDEffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            ThreeDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            ThreeDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            ThreeDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            ThreeDEffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            ThreeDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.textures = asset.images.enumerated().map { index, image in
            MetalTextureFactory.makeTexture(from: image, device: device, label: "3DEffect[\(index)]")
        }
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        animation.isExpired(elapsedTime: elapsedTime)
    }
}
