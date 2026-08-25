//
//  STREffect.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

import RagnarokEffects

public struct STREffect: Sendable {
    public let definition: STREffectDefinition
    public let sound: EffectSound?

    init(definition: STREffectDefinition) {
        self.definition = definition

        self.sound = definition.soundName.map { soundName in
            EffectSound(
                name: soundName.replacingRandomNumber(in: definition.randomNumberRange),
                delay: 0
            )
        }
    }
}
