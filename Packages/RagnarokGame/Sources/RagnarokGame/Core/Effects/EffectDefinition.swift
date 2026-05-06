//
//  EffectDefinition.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

public enum EffectDefinition: Sendable {
    case str(STREffectDefinition)
}

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
