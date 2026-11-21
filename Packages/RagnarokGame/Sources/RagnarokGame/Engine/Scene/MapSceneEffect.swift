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

    /// The object this effect belongs to. The effect ends when that object leaves the map.
    let ownerObjectID: GameObjectID?

    let attachmentKey: EffectAttachmentKey

    let delay: TimeInterval

    let duration: TimeInterval?

    init(
        reference: EffectReference,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        targetObjectID: GameObjectID?,
        ownerObjectID: GameObjectID?,
        attachmentKey: EffectAttachmentKey = .untagged,
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
        self.ownerObjectID = ownerObjectID
        self.attachmentKey = attachmentKey
        self.delay = delay
        self.duration = duration
    }
}
