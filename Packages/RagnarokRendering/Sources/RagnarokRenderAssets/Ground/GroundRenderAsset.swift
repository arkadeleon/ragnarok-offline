//
//  GroundRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics

public struct GroundRenderAsset {
    public var ground: Ground
    public var lighting: WorldLighting
    public var textureImages: [String : CGImage]

    public init(ground: Ground, lighting: WorldLighting, textureImages: [String : CGImage]) {
        self.ground = ground
        self.lighting = lighting
        self.textureImages = textureImages
    }
}
