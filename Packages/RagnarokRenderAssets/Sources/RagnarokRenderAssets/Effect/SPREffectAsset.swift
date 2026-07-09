//
//  SPREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokEffects

public struct SPREffectAsset: Sendable {
    public let definition: SPREffectDefinition
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: CGSize
}
