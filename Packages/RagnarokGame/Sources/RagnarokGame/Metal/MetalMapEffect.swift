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
    let attachedObjectID: GameObjectID?
    let delay: TimeInterval

    var renderResource: EffectRenderResource?

    init(
        reference: EffectReference,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        attachedObjectID: GameObjectID?,
        delay: TimeInterval = 0
    ) {
        self.id = UUID()
        self.reference = reference
        self.creationTime = creationTime
        self.gridPosition = gridPosition
        self.attachedObjectID = attachedObjectID
        self.delay = delay
    }

    var isReady: Bool {
        renderResource != nil
    }

    func isExpired(atTime time: TimeInterval) -> Bool {
        renderResource?.isExpired(atTime: time) ?? false
    }
}
