//
//  SkillEffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

struct SkillEffectDefinition: Sendable {
    var beginCastEffects: [EffectReference] = []
    var effects: [EffectReference] = []
    var beforeHitEffects: [EffectReference] = []
    var hitEffects: [EffectReference] = []
    var successEffects: [EffectReference] = []
}
