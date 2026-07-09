//
//  Effect2DAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import RagnarokEffects

public struct Effect2DAsset: Sendable {
    public let definition: Effect2DDefinition
    public let textureImage: CGImage

    public init(definition: Effect2DDefinition, textureImage: CGImage) {
        self.definition = definition
        self.textureImage = textureImage
    }
}
