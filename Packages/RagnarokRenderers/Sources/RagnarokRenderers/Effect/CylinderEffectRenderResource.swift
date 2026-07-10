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
    public let instance: CylinderEffectAsset.Instance
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: CylinderEffectDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: CylinderEffectAsset, instance: CylinderEffectAsset.Instance) {
        self.asset = asset
        self.instance = instance
        self.vertices = asset.vertices
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(instance: instance, elapsedTime: elapsedTime)
    }

    func sample(elapsedTime: TimeInterval, cameraAzimuth: Float) -> CylinderEffectAsset.Sample? {
        asset.sample(
            instance: instance,
            elapsedTime: elapsedTime,
            cameraAzimuth: cameraAzimuth
        )
    }
}
