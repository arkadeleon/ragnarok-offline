//
//  SPREffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/2.
//

import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokShaders
import simd

public final class SPREffectRenderResource {
    public let asset: SPREffectAsset
    public let vertices: [SPREffectVertex]
    public let textures: [(any MTLTexture)?]
    public let frameSize: SIMD2<Float>

    public var definition: SPREffectDefinition {
        asset.definition
    }

    public var rendersBeforeEntities: Bool {
        asset.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, asset: SPREffectAsset) {
        self.asset = asset
        self.vertices = [
            SPREffectVertex(position: [-0.5,  0.5], textureCoordinate: [0, 0]),
            SPREffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            SPREffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
            SPREffectVertex(position: [ 0.5,  0.5], textureCoordinate: [1, 0]),
            SPREffectVertex(position: [ 0.5, -0.5], textureCoordinate: [1, 1]),
            SPREffectVertex(position: [-0.5, -0.5], textureCoordinate: [0, 1]),
        ]
        self.textures = asset.frameImages.enumerated().map { index, frameImage in
            MetalTextureFactory.makeTexture(from: frameImage, device: device, label: "sprEffect[\(index)]")
        }
        self.frameSize = [
            Float(asset.frameSize.width),
            Float(asset.frameSize.height),
        ]
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        asset.isExpired(elapsedTime: elapsedTime)
    }

    func renderWorldPosition(_ worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        asset.renderWorldPosition(worldPosition)
    }

    func texture(elapsedTime: TimeInterval) -> (any MTLTexture)? {
        guard let frameIndex = asset.frameIndex(atElapsedTime: elapsedTime),
              textures.indices.contains(frameIndex) else {
            return nil
        }
        return textures[frameIndex]
    }
}
