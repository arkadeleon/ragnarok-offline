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
