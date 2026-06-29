//
//  STREffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/25.
//

public struct STREffectDefinition: Sendable {
    public var fileName: String
    public var soundName: String?
    public var attachedToTarget: Bool
    public var randomNumberRange: ClosedRange<Int>?

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
        attachedToTarget: Bool,
        randomNumberRange: ClosedRange<Int>? = nil
    ) -> EffectDefinition {
        let definition = STREffectDefinition(
            fileName: fileName,
            soundName: soundName,
            attachedToTarget: attachedToTarget,
            randomNumberRange: randomNumberRange
        )
        return .str(definition)
    }
}
