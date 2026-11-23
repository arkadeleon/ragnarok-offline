//
//  MapSceneEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Foundation
import RagnarokEffects
import simd

final class MapSceneEffect: Identifiable {
    let id: UUID
    let reference: EffectReference
    let creationTime: TimeInterval
    let gridPosition: SIMD2<Int>
    let worldPosition: SIMD3<Float>

    /// Where the effect starts from, taken when it was cast. A projectile flies from
    /// here to the effect position.
    let sourceWorldPosition: SIMD3<Float>?

    let targetObjectID: GameObjectID?

    let sourceObjectID: GameObjectID?

    /// The object this effect belongs to. The effect ends when that object leaves the map.
    let ownerObjectID: GameObjectID?

    let attachmentKey: EffectAttachmentKey

    let level: Int

    let delay: TimeInterval

    let duration: TimeInterval?

    init(
        reference: EffectReference,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        targetObjectID: GameObjectID?,
        sourceObjectID: GameObjectID? = nil,
        ownerObjectID: GameObjectID?,
        attachmentKey: EffectAttachmentKey = .untagged,
        level: Int = 0,
        delay: TimeInterval = 0,
        duration: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.reference = reference
        self.creationTime = creationTime
        self.gridPosition = gridPosition
        self.worldPosition = worldPosition
        self.sourceWorldPosition = sourceWorldPosition
        self.targetObjectID = targetObjectID
        self.sourceObjectID = sourceObjectID
        self.ownerObjectID = ownerObjectID
        self.attachmentKey = attachmentKey
        self.level = level
        self.delay = delay
        self.duration = duration
    }
}
