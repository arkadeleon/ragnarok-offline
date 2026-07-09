//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import CoreGraphics
import Foundation
import RagnarokEffects

public struct EffectAsset: Sendable {
    public let components: [EffectAssetComponent]
}

public enum EffectAssetComponent: Sendable {
    case `2D`(Effect2DAsset)
    case `3D`(Effect3DAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)

    public var soundName: String? {
        switch self {
        case .`2D`(let asset):
            asset.definition.soundName
        case .`3D`(let asset):
            asset.definition.soundName
        case .cylinder(let asset):
            asset.definition.soundName
        case .spr(let asset):
            asset.definition.soundName
        case .str(let asset):
            asset.definition.soundName
        }
    }
}

public struct Effect2DAsset: Sendable {
    public let definition: Effect2DDefinition
    public let textureImage: CGImage

    public init(definition: Effect2DDefinition, textureImage: CGImage) {
        self.definition = definition
        self.textureImage = textureImage
    }
}

public struct Effect3DAsset: Sendable {
    public struct Layer: Sendable {
        public let imageIndex: Int
        public let sizeFactor: SIMD2<Float>
        public let offset: SIMD2<Float>
        public let angle: Float
        public let color: SIMD4<Float>
        public let isMirrored: Bool

        public init(
            imageIndex: Int,
            sizeFactor: SIMD2<Float>,
            offset: SIMD2<Float> = .zero,
            angle: Float = 0,
            color: SIMD4<Float> = [1, 1, 1, 1],
            isMirrored: Bool = false
        ) {
            self.imageIndex = imageIndex
            self.sizeFactor = sizeFactor
            self.offset = offset
            self.angle = angle
            self.color = color
            self.isMirrored = isMirrored
        }
    }

    public struct Frame: Sendable {
        public let layers: [Effect3DAsset.Layer]
    }

    public let definition: Effect3DDefinition
    public let images: [CGImage]
    public let frames: [Effect3DAsset.Frame]

    public init(definition: Effect3DDefinition, images: [CGImage], frames: [Effect3DAsset.Frame]) {
        self.definition = definition
        self.images = images
        self.frames = frames
    }
}

public struct CylinderEffectAsset: Sendable {
    public let definition: CylinderEffectDefinition
    public let textureImage: CGImage
}

public struct SPREffectAsset: Sendable {
    public let definition: SPREffectDefinition
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: CGSize
}

public struct STREffectAsset: @unchecked Sendable {
    public let definition: STREffectDefinition
    public let effect: STREffect
    public let textureImages: [String : CGImage]
}
