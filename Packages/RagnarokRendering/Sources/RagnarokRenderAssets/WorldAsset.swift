//
//  WorldAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

public struct RSMModelAssetGroup {
    public var prototype: RSMModelRenderAsset
    public var instances: [RSMModelInstance]
}

public struct WorldAsset {
    public var ground: GroundRenderAsset
    public var water: WaterRenderAsset
    public var modelGroups: [RSMModelAssetGroup]
    public var lighting: WorldLighting
}
