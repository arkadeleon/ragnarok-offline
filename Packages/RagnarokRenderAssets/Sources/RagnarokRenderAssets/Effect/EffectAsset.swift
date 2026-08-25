//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

public enum EffectAsset: Sendable {
    case `2D`(TwoDEffectAsset)
    case `3D`(ThreeDEffectAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)
    case wav(WAVEffectAsset)
}
