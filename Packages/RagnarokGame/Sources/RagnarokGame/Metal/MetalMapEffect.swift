//
//  MetalMapEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Foundation
import RagnarokEffects
import RagnarokRenderers
import simd

final class MetalMapEffect: Identifiable {
    let id: UUID
    let effectID: Int
    let effectDefinition: EffectDefinition
    let creationTime: TimeInterval
    let gridPosition: SIMD2<Int>
    let attachedObjectID: GameObjectID?
    let delay: TimeInterval

    var renderResources: [EffectRenderResource] = []

    init(
        effectID: Int,
        effectDefinition: EffectDefinition,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        attachedObjectID: GameObjectID?,
        delay: TimeInterval = 0
    ) {
        self.id = UUID()
        self.effectID = effectID
        self.effectDefinition = effectDefinition
        self.creationTime = creationTime
        self.gridPosition = gridPosition
        self.attachedObjectID = attachedObjectID
        self.delay = delay
    }

    var isReady: Bool {
        !renderResources.isEmpty
    }

    func isExpired(atTime time: TimeInterval) -> Bool {
        !renderResources.isEmpty && renderResources.allSatisfy {
            $0.isExpired(atTime: time)
        }
    }
}
