//
//  EffectReference.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

public enum EffectReference: Sendable {
    case id(EffectID)
    case name(String)
}

extension EffectReference: CustomStringConvertible {
    public var description: String {
        switch self {
        case .id(let effectID):
            String(describing: effectID)
        case .name(let effectName):
            effectName
        }
    }
}
