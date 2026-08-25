//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import RagnarokEffects

public enum EffectAsset: Sendable {
    case `2D`(TwoDEffect, TwoDEffectAsset)
    case `3D`(ThreeDEffect, ThreeDEffectAsset)
    case cylinder(CylinderEffect, CylinderEffectAsset)
    case spr(SPREffect, SPREffectAsset)
    case str(STREffect, STREffectAsset)
    case wav(WAVEffect)
}
