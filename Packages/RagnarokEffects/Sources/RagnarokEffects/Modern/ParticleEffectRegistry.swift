//
//  ParticleEffectRegistry.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation

/// Static registry mapping built-in modern `EffectID`s to their `ParticleEffect` types.
public enum ParticleEffectRegistry {
    private static let effectTypes: [EffectID : ParticleEffect.Type] = {
        var table: [EffectID : ParticleEffect.Type] = [
            // Core emitters
            .ef_emitter: EmitterEffect.self,
            .ef_animated_emitter: AnimatedEmitterEffect.self,

            // Range & utility effects
            .ef_kg_kagehumi: SquareRangeEffect.self,
            .ef_ko_makibishi: CellRangeEffect.self,
            .ef_change_size: ChangeSizeEffect.self,
            .ef_unk_2375: ShowEffect.self,

            // Character particle bundles
            .ef_kr_chop_chop: ChopChopClawMarksEffect.self,
        ]

        // Sprite effects (39 IDs)
        for effectID in SpriteEffect.supportedEffectIDs {
            table[effectID] = SpriteEffect.self
        }

        return table
    }()

    public static let supportedEffectIDs: [EffectID] = {
        effectTypes.keys.sorted()
    }()

    public static func supports(_ effectID: EffectID) -> Bool {
        effectTypes[effectID] != nil
    }

    @MainActor
    public static func make(id: UUID = UUID(), request: EffectSpawnRequest) -> ParticleEffect? {
        effectTypes[request.effectID]?.init(id: id, request: request)
    }
}
