//
//  WorldEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/15.
//

import RagnarokConstants
import simd

public struct WorldEffectAsset: Sendable {
    public var effectID: EffectID
    public var position: SIMD3<Float>
    public var assetGroup: EffectAssetGroup

    public init(effectID: EffectID, position: SIMD3<Float>, assetGroup: EffectAssetGroup) {
        self.effectID = effectID
        self.position = position
        self.assetGroup = assetGroup
    }
}
