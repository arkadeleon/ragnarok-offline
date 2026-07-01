//
//  EffectReference.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

public enum EffectReference: Sendable {
    case id(Int)
    case name(String)
}

extension EffectReference: CustomStringConvertible {
    public var description: String {
        switch self {
        case .id(let effectID):
            "\(effectID)"
        case .name(let effectName):
            effectName
        }
    }
}
