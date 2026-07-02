//
//  EffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import CoreGraphics
import Foundation
import RagnarokEffects

public enum EffectAsset: @unchecked Sendable {
    case `3D`(Effect3DAsset)
    case cylinder(CylinderEffectAsset)
    case spr(SPREffectAsset)
    case str(STREffectAsset)
}

public struct Effect3DAsset: Sendable {
    public let definition: Effect3DDefinition
    public let textureImages: [CGImage]
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

public struct STREffectAsset {
    public let definition: STREffectDefinition
    public let effect: STREffect
    public let textureImages: [String : CGImage]
}
