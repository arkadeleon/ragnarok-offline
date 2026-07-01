//
//  EffectReference.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import RagnarokConstants

public enum EffectReference: Sendable {
    case id(EffectID)
    case name(String)
}

extension EffectReference: CustomStringConvertible {
    public var description: String {
        switch self {
        case .id(let effectID):
            effectID.stringValue.lowercased()
        case .name(let effectName):
            effectName
        }
    }
}
