//
//  Effect2DRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/9.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class Effect2DRenderResource {
    public let asset: Effect2DAsset
    public let vertices: [Effect2DVertex]
    public let texture: (any MTLTexture)?
    public let duplicateID: Int

    public var definition: Effect2DDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: Effect2DAsset, duplicateID: Int = 0) {
        self.asset = asset
        self.vertices = [
            Effect2DVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            Effect2DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect2DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            Effect2DVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            Effect2DVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            Effect2DVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "effect2D")
        self.duplicateID = duplicateID
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(forDuplicateID: duplicateID, elapsedTime: elapsedTime)
    }

    func sample(elapsedTime: TimeInterval, worldPosition: SIMD3<Float>, cameraAzimuth: Float) -> Effect2DAsset.Sample? {
        asset.sample(
            forDuplicateID: duplicateID,
            elapsedTime: elapsedTime,
            worldPosition: worldPosition,
            cameraAzimuth: cameraAzimuth
        )
    }
}
