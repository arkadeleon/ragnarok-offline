//
//  EffectDefinition.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

public enum EffectDefinition: Sendable {
    case str(STREffectDefinition)

    static func str(
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

extension EffectDefinition {
    var soundName: String? {
        switch self {
        case .str(let definition):
            definition.soundName
        }
    }

    var assetKey: String {
        switch self {
        case .str(let definition):
            "str:\(definition.fileName)"
        }
    }

    func resolved() -> EffectDefinition {
        switch self {
        case .str(let definition):
            .str(definition.resolved())
        }
    }
}
