//
//  CylinderEffectRenderResource.swift
//  RagnarokRendering
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
    public let instance: CylinderEffect.Instance
    public let vertices: [CylinderEffectVertex]
    public let texture: (any MTLTexture)?

    public var definition: CylinderEffectDefinition {
        asset.effect.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.effect.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: CylinderEffectAsset, instance: CylinderEffect.Instance) {
        self.asset = asset
        self.instance = instance
        self.vertices = asset.vertices
        self.texture = MetalTextureFactory.makeTexture(from: asset.textureImage, device: device, label: "cylinderEffect")
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.effect.isExpired(instance: instance, elapsedTime: elapsedTime)
    }

    func sample(
        forElapsedTime elapsedTime: TimeInterval,
        cameraAzimuth: Float,
        cameraElevation: Float
    ) -> CylinderEffect.Sample? {
        asset.effect.sample(
            forInstance: instance,
            elapsedTime: elapsedTime,
            cameraAzimuth: cameraAzimuth,
            cameraElevation: cameraElevation
        )
    }
}
