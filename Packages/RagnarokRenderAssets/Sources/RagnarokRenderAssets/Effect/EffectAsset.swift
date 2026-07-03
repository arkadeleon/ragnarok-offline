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
    case `3D`(Effect3DAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)

    public var definition: EffectDefinition {
        switch self {
        case .`3D`(let asset):
            .`3D`(asset.definition)
        case .cylinder(let asset):
            .cylinder(asset.definition)
        case .spr(let asset):
            .spr(asset.definition)
        case .str(let asset):
            .str(asset.definition)
        }
    }
}

public struct Effect3DAsset: Sendable {
    public struct Texture: Sendable {
        public let image: CGImage
        public let sizeFactor: SIMD2<Float>
    }

    public let definition: Effect3DDefinition
    public let textures: [Effect3DAsset.Texture]
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
