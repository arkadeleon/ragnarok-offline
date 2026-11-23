//
//  STREffectAsset.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Metal

public struct STREffectAsset: @unchecked Sendable {
    public let animation: STREffectAnimation
    public let textures: [String : any MTLTexture]

    public init(animation: STREffectAnimation, textures: [String : any MTLTexture]) {
        self.animation = animation
        self.textures = textures
    }
}
