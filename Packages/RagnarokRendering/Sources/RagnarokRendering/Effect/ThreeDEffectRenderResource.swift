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
    public let asset: ThreeDEffectAsset
    public let instance: ThreeDEffect.Instance
    public let vertices: [ThreeDEffectVertex]
    public let textures: [(any MTLTexture)?]

    public var definition: ThreeDEffectDefinition {
        asset.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.effect.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: ThreeDEffectAsset, instance: ThreeDEffect.Instance) {
        self.asset = asset
        self.instance = instance
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
        asset.effect.isExpired(instance: instance, elapsedTime: elapsedTime)
    }

    func sample(
        forElapsedTime elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> ThreeDEffect.Sample? {
        asset.effect.sample(
            forInstance: instance,
            elapsedTime: elapsedTime,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            targetWorldPosition: targetWorldPosition,
            cameraAzimuth: cameraAzimuth
        )
    }
}
