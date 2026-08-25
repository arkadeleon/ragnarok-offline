//
//  WAVEffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/8/25.
//

import Foundation

// Ported from roBrowserLegacy EffectTable.js (Swift property → JS key):
// - soundName:          wav
// - randomNumberRange:  rand
// - delaySound:         delayWav
public struct WAVEffectDefinition: Sendable {
    public var soundName: String
    public var randomNumberRange: ClosedRange<Int>?
    public var delaySound: TimeInterval
}

extension EffectDefinition {
    public static func wav(
        soundName: String,
        randomNumberRange: ClosedRange<Int>? = nil,
        delaySound: TimeInterval = 0
    ) -> EffectDefinition {
        let definition = WAVEffectDefinition(
            soundName: soundName,
            randomNumberRange: randomNumberRange,
            delaySound: delaySound
        )
        return .wav(definition)
    }
}
