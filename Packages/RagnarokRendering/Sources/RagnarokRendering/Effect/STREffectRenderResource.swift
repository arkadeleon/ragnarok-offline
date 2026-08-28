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
    public let fps: Int
    public let frames: [STREffectAnimation.Frame]
    public let textures: [String : any MTLTexture]
    public let duration: TimeInterval

    public convenience init(
        device: any MTLDevice,
        effect: STREffect,
        animation: STREffectAnimation,
        duration: TimeInterval? = nil
    ) {
        self.init(
            device: device,
            definition: effect.definition,
            animation: animation,
            duration: duration
        )
    }

    public init(
        device: any MTLDevice,
        definition: STREffectDefinition? = nil,
        animation: STREffectAnimation,
        duration: TimeInterval? = nil
    ) {
        var textures: [String : any MTLTexture] = [:]
        for (textureName, textureImage) in animation.textureImages {
            if let texture = MetalTextureFactory.makeTexture(from: textureImage, device: device, label: textureName) {
                textures[textureName] = texture
            }
        }

        self.definition = definition
        self.fps = animation.fps
        self.frames = animation.frames
        self.textures = textures
        self.duration = duration ?? animation.duration
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        guard elapsedTime >= 0 else {
            return false
        }
        return elapsedTime >= duration
    }

    public func frame(atElapsedTime elapsedTime: TimeInterval) -> STREffectAnimation.Frame? {
        guard !frames.isEmpty, elapsedTime >= 0 else {
            return nil
        }

        let frameIndex = Int(elapsedTime * TimeInterval(fps)) % frames.count
        return frames[frameIndex]
    }
}
