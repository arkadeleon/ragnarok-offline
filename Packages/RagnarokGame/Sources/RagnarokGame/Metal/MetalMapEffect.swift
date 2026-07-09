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
    let reference: EffectReference
    let creationTime: TimeInterval
    let gridPosition: SIMD2<Int>
    let worldPosition: SIMD3<Float>
    let spritePosition: SIMD3<Float>
    let targetObjectID: GameObjectID?
    let delay: TimeInterval

    var renderResourceGroup: EffectRenderResourceGroup?

    init(
        reference: EffectReference,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        worldPosition: SIMD3<Float>,
        spritePosition: SIMD3<Float>,
        targetObjectID: GameObjectID?,
        delay: TimeInterval = 0
    ) {
        self.id = UUID()
        self.reference = reference
        self.creationTime = creationTime
        self.gridPosition = gridPosition
        self.worldPosition = worldPosition
        self.spritePosition = spritePosition
        self.targetObjectID = targetObjectID
        self.delay = delay
    }

    var isReady: Bool {
        renderResourceGroup != nil
    }

    func isExpired(atTime time: TimeInterval) -> Bool {
        renderResourceGroup?.isExpired(atTime: time) ?? false
    }
}
