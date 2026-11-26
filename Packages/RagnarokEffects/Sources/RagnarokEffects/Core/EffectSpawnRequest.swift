//
//  EffectSpawnRequest.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import simd

/// Request payload used to spawn an effect through `EffectManager`.
public struct EffectSpawnRequest: Sendable {
    public var effectID: EffectID
    public var worldPosition: SIMD3<Float>
    public var sourceWorldPosition: SIMD3<Float>?
    public var ownerObjectID: EffectTargetID?
    public var targetObjectID: EffectTargetID?
    public var sourceObjectID: EffectTargetID?
    public var attachmentKey: EffectAttachmentKey
    public var direction: SIMD3<Float>?
    public var level: Int
    public var delay: TimeInterval
    public var duration: TimeInterval?
    public var parameters: [Float]
    public var extraParams: SIMD3<Float>?

    public var effectPosition: SIMD3<Float> {
        EffectSpace.toEffectPosition(worldPosition)
    }

    public var sourceEffectPosition: SIMD3<Float>? {
        sourceWorldPosition.map(EffectSpace.toEffectPosition)
    }

    public init(
        effectID: EffectID,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        ownerObjectID: EffectTargetID? = nil,
        targetObjectID: EffectTargetID? = nil,
        sourceObjectID: EffectTargetID? = nil,
        attachmentKey: EffectAttachmentKey = .untagged,
        direction: SIMD3<Float>? = nil,
        level: Int = 0,
        delay: TimeInterval = 0,
        duration: TimeInterval? = nil,
        parameters: [Float] = [],
        extraParams: SIMD3<Float>? = nil
    ) {
        self.effectID = effectID
        self.worldPosition = worldPosition
        self.sourceWorldPosition = sourceWorldPosition
        self.ownerObjectID = ownerObjectID
        self.targetObjectID = targetObjectID
        self.sourceObjectID = sourceObjectID
        self.attachmentKey = attachmentKey
        self.direction = direction
        self.level = level
        self.delay = delay
        self.duration = duration
        self.parameters = parameters
        self.extraParams = extraParams
    }
}
