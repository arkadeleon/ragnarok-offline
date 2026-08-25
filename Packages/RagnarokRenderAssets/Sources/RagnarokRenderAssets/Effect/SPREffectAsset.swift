//
//  SPREffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/9.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokFileFormats
import RagnarokResources

public struct SPREffectAsset: Sendable {
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: SIMD2<Float>

    static func load(fileName: String, actionIndex: Int, using resourceManager: ResourceManager, cache: EffectAssetCache) async throws -> SPREffectAsset {
        try await cache.resource(forIdentifier: "SPREffect/\(fileName)#\(actionIndex)") {
            let spritePath = ResourcePath.spriteDirectory
                .appending(K2L("이팩트"))
                .appending(fileName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)

            let action = act.action(at: actionIndex)
            let animation = action?.animation(using: spr.imagesBySpriteType())

            return SPREffectAsset(
                frameImages: animation?.frames.compactMap { $0 } ?? [],
                frameInterval: TimeInterval(animation?.frameInterval ?? 1 / 12),
                frameSize: [
                    Float(animation?.frameWidth ?? 0),
                    Float(animation?.frameHeight ?? 0),
                ]
            )
        }
    }
}
