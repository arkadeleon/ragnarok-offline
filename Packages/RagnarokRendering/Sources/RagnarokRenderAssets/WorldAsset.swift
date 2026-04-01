//
//  WorldAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

public struct WorldAsset {
    public var ground: GroundRenderAsset
    public var water: WaterRenderAsset
    public var models: [RSMModelRenderAsset]
    public var lighting: WorldLighting

    public init(
        ground: GroundRenderAsset,
        water: WaterRenderAsset,
        models: [RSMModelRenderAsset],
        lighting: WorldLighting
    ) {
        self.ground = ground
        self.water = water
        self.models = models
        self.lighting = lighting
    }
}
