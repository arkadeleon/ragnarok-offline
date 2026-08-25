//
//  WAVEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/8/25.
//

public struct WAVEffect: Sendable {
    public let definition: WAVEffectDefinition
    public let sound: EffectSound

    public init(definition: WAVEffectDefinition) {
        self.definition = definition

        self.sound = EffectSound(
            name: definition.soundName.replacingRandomNumber(in: definition.randomNumberRange),
            delay: definition.delaySound
        )
    }
}
