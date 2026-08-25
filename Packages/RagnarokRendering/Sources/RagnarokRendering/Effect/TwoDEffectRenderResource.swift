//
//  TwoDEffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/7/9.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class TwoDEffectRenderResource {
    public let animation: TwoDEffectAnimation
    public let vertices: [TwoDEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: TwoDEffectDefinition {
        animation.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, effect: TwoDEffect, instance: TwoDEffect.Instance, asset: TwoDEffectAsset) {
        self.animation = TwoDEffectAnimation(effect: effect, instance: instance)
        self.vertices = [
            TwoDEffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            TwoDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            TwoDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            TwoDEffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            TwoDEffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            TwoDEffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "2DEffect")
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        animation.isExpired(elapsedTime: elapsedTime)
    }
}
