//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

public enum EffectAsset: Sendable {
    case `2D`(Effect2DAsset)
    case `3D`(Effect3DAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)

    public var soundName: String? {
        switch self {
        case .`2D`(let asset):
            asset.definition.soundName
        case .`3D`(let asset):
            asset.definition.soundName
        case .cylinder(let asset):
            asset.definition.soundName
        case .spr(let asset):
            asset.definition.soundName
        case .str(let asset):
            asset.definition.soundName
        }
    }
}
