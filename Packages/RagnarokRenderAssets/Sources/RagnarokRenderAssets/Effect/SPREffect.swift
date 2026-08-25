//
//  SPREffect.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

import RagnarokEffects

public struct SPREffect: Sendable {
    public let definition: SPREffectDefinition
    public let sound: EffectSound?

    init(definition: SPREffectDefinition) {
        self.definition = definition

        self.sound = definition.soundName.map { soundName in
            EffectSound(name: soundName, delay: 0)
        }
    }
}
