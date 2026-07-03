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

    public convenience init(
        device: any MTLDevice,
        asset: STREffectAsset,
        spritePosition: SIMD3<Float>
    ) {
        self.init(device: device, effect: asset.effect, textureImages: asset.textureImages, spritePosition: spritePosition)
    }

    public init(
        device: any MTLDevice,
        effect: STREffect,
        textureImages: [String : CGImage],
        spritePosition: SIMD3<Float>
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
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        let duration = TimeInterval(effect.frames.count) / TimeInterval(effect.fps)
        guard elapsedTime >= 0 else {
            return false
        }
        return elapsedTime >= duration
    }
}
