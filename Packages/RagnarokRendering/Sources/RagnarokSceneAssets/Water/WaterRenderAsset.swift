//
//  WaterRenderAsset.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics

public struct WaterRenderAsset {
    public var water: Water
    public var textureImage: CGImage?

    public init(water: Water, textureImage: CGImage?) {
        self.water = water
        self.textureImage = textureImage
    }
}
