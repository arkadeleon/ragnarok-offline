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
    public var textureImages: [String : CGImage]
    public var instances: [RSMModelInstance]

    public init(
        name: String,
        model: RSMModel,
        textureImages: [String : CGImage],
        instances: [RSMModelInstance]
    ) {
        self.name = name
        self.model = model
        self.textureImages = textureImages
        self.instances = instances
    }
}
