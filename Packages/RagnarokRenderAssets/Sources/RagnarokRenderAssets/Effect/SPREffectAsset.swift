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
    public let definition: SPREffectDefinition
    public let frameImages: [CGImage]
    public let frameInterval: TimeInterval
    public let frameSize: CGSize

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
        let frameImages = animation?.frames.compactMap { $0 } ?? []
        let frameInterval = definition.frameInterval ?? TimeInterval(animation?.frameInterval ?? 1 / 12)
        let frameSize = CGSize(
            width: animation?.frameWidth ?? 0,
            height: animation?.frameHeight ?? 0
        )

        let asset = SPREffectAsset(
            definition: definition,
            frameImages: frameImages,
            frameInterval: frameInterval,
            frameSize: frameSize
        )
        return asset
    }
}

extension SPREffectAsset {
    private var playbackFrameInterval: TimeInterval {
        max(frameInterval, 1 / 60)
    }

    public func isExpired(elapsedTime: TimeInterval) -> Bool {
        if definition.stopsAtEnd {
            return false
        }

        guard elapsedTime >= 0 else {
            return false
        }

        if let duration = definition.duration {
            return elapsedTime >= duration
        }

        if definition.repeats {
            return false
        }

        return elapsedTime >= TimeInterval(frameImages.count) * playbackFrameInterval
    }

    public func frameIndex(atElapsedTime elapsedTime: TimeInterval) -> Int? {
        guard !frameImages.isEmpty, elapsedTime >= 0 else {
            return nil
        }

        if definition.repeats {
            return Int(elapsedTime / playbackFrameInterval) % frameImages.count
        } else {
            return min(Int(elapsedTime / playbackFrameInterval), frameImages.count - 1)
        }
    }

    public func adjustedWorldPosition(_ worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        var basePosition = worldPosition
        if definition.rendersAtHead {
            basePosition.z += 2.5
        }

        return basePosition + [definition.spriteOffset.x / 35, 0, -definition.spriteOffset.y / 35]
    }
}
