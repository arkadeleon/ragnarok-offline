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

    public convenience init(device: any MTLDevice, asset: STREffectAsset) {
        self.init(
            device: device,
            definition: asset.definition,
            animation: asset.animation,
            textureImages: asset.textureImages
        )
    }

    public init(
        device: any MTLDevice,
        definition: STREffectDefinition? = nil,
        animation: STRAnimation,
        textureImages: [String : CGImage]
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
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard elapsedTime >= 0 else {
            return false
        }
        return elapsedTime >= animation.duration
    }
}
