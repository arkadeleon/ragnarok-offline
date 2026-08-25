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
    public let asset: TwoDEffectAsset
    public let instance: TwoDEffect.Instance
    public let vertices: [TwoDEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: TwoDEffectDefinition {
        asset.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.effect.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: TwoDEffectAsset, instance: TwoDEffect.Instance) {
        self.asset = asset
        self.instance = instance
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
        asset.effect.isExpired(instance: instance, elapsedTime: elapsedTime)
    }

    func sample(forElapsedTime elapsedTime: TimeInterval, worldPosition: SIMD3<Float>, cameraAzimuth: Float) -> TwoDEffect.Sample? {
        asset.effect.sample(
            forInstance: instance,
            elapsedTime: elapsedTime,
            worldPosition: worldPosition,
            cameraAzimuth: cameraAzimuth
        )
    }
}
