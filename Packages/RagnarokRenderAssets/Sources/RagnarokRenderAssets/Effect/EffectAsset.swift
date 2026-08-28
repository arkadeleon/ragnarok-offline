//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects

public enum EffectAsset: Sendable {
    case `2D`(TwoDEffect, textureImage: CGImage)
    case `3D`(ThreeDEffect, animation: ThreeDEffectAnimation)
    case cylinder(CylinderEffect, textureImage: CGImage)
    case spr(SPREffect, animation: SPREffectAnimation)
    case str(STREffect, animation: STREffectAnimation)
    case wav(WAVEffect)
}
