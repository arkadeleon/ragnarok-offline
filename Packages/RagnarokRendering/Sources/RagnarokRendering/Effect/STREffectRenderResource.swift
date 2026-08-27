//
//  STREffectRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/4/30.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokEffects
import RagnarokRenderAssets
import simd

public final class STREffectRenderResource {
    public let definition: STREffectDefinition?
    public let animation: STRAnimation
    public let textures: [String : any MTLTexture]
    public let duration: TimeInterval

    public convenience init(
        device: any MTLDevice,
        effect: STREffect,
        asset: STREffectAsset,
        duration: TimeInterval? = nil
    ) {
        self.init(
            device: device,
            definition: effect.definition,
            animation: asset.animation,
            textureImages: asset.textureImages,
            duration: duration
        )
    }

    public init(
        device: any MTLDevice,
        definition: STREffectDefinition? = nil,
        animation: STRAnimation,
        textureImages: [String : CGImage],
        duration: TimeInterval? = nil
    ) {
        var textures: [String : any MTLTexture] = [:]
        for (textureName, textureImage) in textureImages {
            if let texture = MetalTextureFactory.makeTexture(from: textureImage, device: device, label: textureName) {
                textures[textureName] = texture
            }
        }

        self.definition = definition
        self.animation = animation
        self.textures = textures
        self.duration = duration ?? animation.duration
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard elapsedTime >= 0 else {
            return false
        }
        return elapsedTime >= duration
    }
}
