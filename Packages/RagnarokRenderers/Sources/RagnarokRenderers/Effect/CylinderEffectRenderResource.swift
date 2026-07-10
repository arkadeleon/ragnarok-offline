//
//  CylinderEffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/25.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class CylinderEffectRenderResource {
    public let asset: CylinderEffectAsset
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?
    public let duplicateID: Int

    public var definition: CylinderEffectDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: CylinderEffectAsset, duplicateID: Int = 0) {
        self.asset = asset
        self.vertices = asset.vertices
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
        self.duplicateID = duplicateID
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(forDuplicateID: duplicateID, elapsedTime: elapsedTime)
    }

    func sample(elapsedTime: TimeInterval, cameraAzimuth: Float) -> CylinderEffectAsset.Sample? {
        asset.sample(
            forDuplicateID: duplicateID,
            elapsedTime: elapsedTime,
            cameraAzimuth: cameraAzimuth
        )
    }
}
