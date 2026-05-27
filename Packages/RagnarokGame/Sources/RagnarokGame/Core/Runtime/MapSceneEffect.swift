//
//  MapSceneEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import simd

public struct MapSceneEffect: Identifiable, Sendable {
    public let id: UUID
    public let effectID: Int
    public let effectDefinition: EffectDefinition
    public let creationTime: ContinuousClock.Instant
    public let gridPosition: SIMD2<Int>
    public let attachedObjectID: GameObjectID?
    public let delay: Duration

    public init(
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
