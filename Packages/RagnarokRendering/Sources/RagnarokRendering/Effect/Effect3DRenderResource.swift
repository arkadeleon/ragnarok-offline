//
//  Effect3DRenderResource.swift
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

public final class Effect3DRenderResource {
    public let asset: ThreeDEffectAsset
    public let instance: ThreeDEffectAsset.Instance
    public let vertices: [Effect3DVertex]
    public let textures: [(any MTLTexture)?]

    public var definition: ThreeDEffectDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: ThreeDEffectAsset, instance: ThreeDEffectAsset.Instance) {
        self.asset = asset
        self.instance = instance
        self.vertices = [
            Effect3DVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            Effect3DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect3DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            Effect3DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect3DVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            Effect3DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.textures = asset.images.enumerated().map { index, image in
            MetalTextureFactory.makeTexture(from: image, device: device, label: "effect3D[\(index)]")
        }
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(instance: instance, elapsedTime: elapsedTime)
    }

    func sample(
        forElapsedTime elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>,
        cameraAzimuth: Float
    ) -> ThreeDEffectAsset.Sample? {
        asset.sample(
            forInstance: instance,
            elapsedTime: elapsedTime,
            worldPosition: worldPosition,
            sourceWorldPosition: sourceWorldPosition,
            targetWorldPosition: targetWorldPosition,
            cameraAzimuth: cameraAzimuth
        )
    }
}
