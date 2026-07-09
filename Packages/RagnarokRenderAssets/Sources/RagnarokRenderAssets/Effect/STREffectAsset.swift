//
//  STREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects

public struct STREffectAsset: @unchecked Sendable {
    public let definition: STREffectDefinition
    public let effect: STREffect
    public let textureImages: [String : CGImage]
}
