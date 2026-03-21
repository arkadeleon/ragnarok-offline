//
//  MapWorldAsset.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2026/3/21.
//

import RagnarokRenderers

public struct MapWorldAsset {
    public var ground: GroundRenderAsset
    public var water: WaterRenderAsset
    public var models: [ModelRenderAsset]
    public var lighting: WorldLighting

    public init(
        ground: GroundRenderAsset,
        water: WaterRenderAsset,
        models: [ModelRenderAsset],
        lighting: WorldLighting
    ) {
        self.ground = ground
        self.water = water
        self.models = models
        self.lighting = lighting
    }
}
