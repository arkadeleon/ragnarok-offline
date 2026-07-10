//
//  Effect3DRenderResource.swift
//  RagnarokRenderers
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
    public let asset: Effect3DAsset
    public let vertices: [Effect3DVertex]
    public let textures: [(any MTLTexture)?]
    public let duplicateID: Int

    public var definition: Effect3DDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: Effect3DAsset, duplicateID: Int = 0) {
        self.asset = asset
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
        self.duplicateID = duplicateID
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(forDuplicateID: duplicateID, elapsedTime: elapsedTime)
    }

    func sample(elapsedTime: TimeInterval, worldPosition: SIMD3<Float>, cameraAzimuth: Float) -> Effect3DAsset.Sample? {
        asset.sample(
            forDuplicateID: duplicateID,
            elapsedTime: elapsedTime,
            worldPosition: worldPosition,
            cameraAzimuth: cameraAzimuth
        )
    }
}
