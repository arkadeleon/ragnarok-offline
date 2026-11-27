//
//  ShowEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation

/// Container effect tracking tagged child effects attached to an actor (`EF_SHOW_EFFECT` / 2375).
@MainActor
public final class ShowEffect: ParticleEffect {
    public private(set) var taggedEffects: [Int : EffectID] = [:]

    public var count: Int {
        taggedEffects.count
    }

    public func add(tag: Int, effectID: EffectID, context: EffectTickContext) {
        guard taggedEffects[tag] == nil else {
            return
        }
        let childRequest = EffectSpawnRequest(
            effectID: effectID,
            worldPosition: EffectSpace.toWorldPosition(position),
            ownerObjectID: ownerObjectID,
            targetObjectID: targetObjectID,
            attachmentKey: .status(tag)
        )
        context.spawnChildEffect(childRequest)
        taggedEffects[tag] = effectID
    }

    public func remove(tag: Int) {
        taggedEffects.removeValue(forKey: tag)
    }

    public override func close() {
        taggedEffects.removeAll()
    }
}
