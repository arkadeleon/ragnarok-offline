//
//  MetalSkillEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Foundation
import simd

struct MetalSkillEffect: Identifiable, Sendable {
    let id: UUID
    let effectID: Int
    let effectDefinition: EffectDefinition
    let creationTime: ContinuousClock.Instant
    let gridPosition: SIMD2<Int>
    let attachedObjectID: GameObjectID?
    let delay: Duration

    init(
        effectID: Int,
        effectDefinition: EffectDefinition,
        creationTime: ContinuousClock.Instant,
        gridPosition: SIMD2<Int>,
        attachedObjectID: GameObjectID?,
        delay: Duration = .zero
    ) {
        self.id = UUID()
        self.effectID = effectID
        self.effectDefinition = effectDefinition
        self.creationTime = creationTime
        self.gridPosition = gridPosition
        self.attachedObjectID = attachedObjectID
        self.delay = delay
    }
}
