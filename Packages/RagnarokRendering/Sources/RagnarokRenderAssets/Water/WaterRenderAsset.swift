//
//  WaterRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics

public struct WaterRenderAsset {
    public var water: Water
    public var lighting: WorldLighting
    public var textureImage: CGImage?

    public init(water: Water, lighting: WorldLighting, textureImage: CGImage?) {
        self.water = water
        self.lighting = lighting
        self.textureImage = textureImage
    }
}
