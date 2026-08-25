//
//  WAVEffectAsset.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

import RagnarokEffects

public struct WAVEffectAsset: Sendable {
    public let definition: WAVEffectDefinition
    public let sound: EffectSound

    init(definition: WAVEffectDefinition) {
        self.definition = definition

        self.sound = EffectSound(
            name: definition.soundName.replacingRandomNumber(in: definition.randomNumberRange),
            delay: definition.delaySound
        )
    }
}
