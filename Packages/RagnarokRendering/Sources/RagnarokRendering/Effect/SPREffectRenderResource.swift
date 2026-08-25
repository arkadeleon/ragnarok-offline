//
//  SPREffectRenderResource.swift
//  RagnarokRendering
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
    public let effect: SPREffect
    public let vertices: [SPREffectVertex]
    public let textures: [(any MTLTexture)?]
    public let frameSize: SIMD2<Float>

    private let playbackFrameInterval: TimeInterval

    public var definition: SPREffectDefinition {
        effect.definition
    }

    public var rendersBeforeEntities: Bool {
        effect.definition.rendersBeforeEntities
    }

    public init(device: any MTLDevice, effect: SPREffect, asset: SPREffectAsset) {
        self.effect = effect

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
        self.frameSize = asset.frameSize

        // The definition may override the sprite's own interval.
        self.playbackFrameInterval = max(effect.definition.frameInterval ?? asset.frameInterval, 1 / 60)
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        if definition.stopsAtEnd {
            return false
        }

        guard elapsedTime >= 0 else {
            return false
        }

        if let duration = definition.duration {
            return elapsedTime >= duration
        }

        if definition.repeats {
            return false
        }

        return elapsedTime >= TimeInterval(textures.count) * playbackFrameInterval
    }

    func adjustedWorldPosition(_ worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        var basePosition = worldPosition
        if definition.rendersAtHead {
            basePosition.z += 2.5
        }

        return basePosition + [definition.spriteOffset.x / 35, 0, -definition.spriteOffset.y / 35]
    }

    func texture(elapsedTime: TimeInterval) -> (any MTLTexture)? {
        guard !textures.isEmpty, elapsedTime >= 0 else {
            return nil
        }

        let frameIndex: Int
        if definition.repeats {
            frameIndex = Int(elapsedTime / playbackFrameInterval) % textures.count
        } else {
            frameIndex = min(Int(elapsedTime / playbackFrameInterval), textures.count - 1)
        }

        return textures[frameIndex]
    }
}
