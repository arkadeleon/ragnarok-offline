//
//  STREffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/8/25.
//

public struct STREffect: Sendable {
    public let definition: STREffectDefinition
    public let fileName: String
    public let sound: EffectSound?

    public init(definition: STREffectDefinition) {
        self.definition = definition

        self.fileName = definition.fileName.replacingRandomNumber(in: definition.randomNumberRange)

        self.sound = definition.soundName.map { soundName in
            EffectSound(
                name: soundName.replacingRandomNumber(in: definition.randomNumberRange),
                delay: 0
            )
        }
    }
}
