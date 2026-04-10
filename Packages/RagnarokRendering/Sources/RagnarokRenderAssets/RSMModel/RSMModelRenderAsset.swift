//
//  RSMModelRenderAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import simd

public struct RSMModelRenderAsset {
    public var name: String
    public var model: RSMModel
    public var instance: RSMModelInstance
    public var lighting: WorldLighting
    public var textureImages: [String : CGImage]

    public init(
        name: String,
        model: RSMModel,
        instance: RSMModelInstance,
        lighting: WorldLighting,
        textureImages: [String : CGImage],
    ) {
        self.name = name
        self.model = model
        self.instance = instance
        self.lighting = lighting
        self.textureImages = textureImages
    }
}
