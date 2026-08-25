//
//  SPREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct SPREffectAsset: Sendable {
    public let effect: SPREffect
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: SIMD2<Float>

    static func load(with definition: SPREffectDefinition, using resourceManager: ResourceManager) async throws -> SPREffectAsset {
        let spritePath = ResourcePath.spriteDirectory
            .appending(K2L("이팩트"))
            .appending(definition.fileName)

        async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
        async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

        let act = try await ACT(data: actData)
        let spr = try await SPR(data: sprData)

        let action = act.action(at: definition.actionIndex)
        let animation = action?.animation(using: spr.imagesBySpriteType())

        let asset = SPREffectAsset(
            effect: SPREffect(definition: definition),
            frameImages: animation?.frames.compactMap { $0 } ?? [],
            frameInterval: definition.frameInterval ?? TimeInterval(animation?.frameInterval ?? 1 / 12),
            frameSize: [
                Float(animation?.frameWidth ?? 0),
                Float(animation?.frameHeight ?? 0),
            ]
        )
        return asset
    }
}
