//
//  STREffectRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/4/30.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokRenderAssets
import simd

public final class STREffectRenderResource {
    public let effect: STREffect
    public let textures: [String : any MTLTexture]
    public let spritePosition: SIMD3<Float>
    public let creationTime: TimeInterval
    public let delay: TimeInterval

    public var startTime: TimeInterval {
        creationTime + delay
    }

    public convenience init(
        device: any MTLDevice,
        asset: STREffectAsset,
        spritePosition: SIMD3<Float>,
        creationTime: TimeInterval,
        delay: TimeInterval = 0
    ) {
        self.init(device: device, effect: asset.effect, textureImages: asset.textureImages, spritePosition: spritePosition, creationTime: creationTime, delay: delay)
    }

    public init(
        device: any MTLDevice,
        effect: STREffect,
        textureImages: [String : CGImage],
        spritePosition: SIMD3<Float>,
        creationTime: TimeInterval,
        delay: TimeInterval = 0
    ) {
        var textures: [String : any MTLTexture] = [:]
        for (textureName, textureImage) in textureImages {
            if let texture = MetalTextureFactory.makeTexture(from: textureImage, device: device, label: textureName) {
                textures[textureName] = texture
            }
        }

        self.effect = effect
        self.textures = textures
        self.spritePosition = spritePosition
        self.creationTime = creationTime
        self.delay = delay
    }

    public func isExpired(atTime time: TimeInterval) -> Bool {
        let duration = TimeInterval(effect.frames.count) / TimeInterval(effect.fps)
        let elapsedTime = time - startTime
        guard elapsedTime >= 0 else {
            return false
        }
        return elapsedTime >= duration
    }
}
