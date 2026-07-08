//
//  STREffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/25.
//

// Ported from roBrowserLegacy EffectTable.js (Swift property → JS key):
// - fileName:           file
// - soundName:          wav
// - randomNumberRange:  rand
// - attachedToTarget:   attachedEntity
public struct STREffectDefinition: Sendable {
    public var fileName: String
    public var soundName: String?
    public var randomNumberRange: ClosedRange<Int>?

    public var attachedToTarget: Bool

    func resolved() -> STREffectDefinition {
        guard let randomNumberRange else {
            return self
        }

        var definition = self
        let randomNumber = Int.random(in: randomNumberRange)
        definition.fileName = fileName.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        definition.soundName = soundName?.replacingOccurrences(of: "%d", with: "\(randomNumber)")
        definition.randomNumberRange = nil
        return definition
    }
}

extension EffectDefinition {
    public static func str(
        fileName: String,
        soundName: String? = nil,
        randomNumberRange: ClosedRange<Int>? = nil,
        attachedToTarget: Bool
    ) -> EffectDefinition {
        let definition = STREffectDefinition(
            fileName: fileName,
            soundName: soundName,
            randomNumberRange: randomNumberRange,
            attachedToTarget: attachedToTarget
        )
        return .str(definition)
    }
}
