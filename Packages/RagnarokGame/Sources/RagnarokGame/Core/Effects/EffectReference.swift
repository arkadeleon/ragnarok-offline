//
//  EffectReference.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

enum EffectReference: Sendable {
    case id(Int)
    case name(String)

    var effectID: Int? {
        switch self {
        case .id(let effectID):
            effectID
        case .name:
            nil
        }
    }
}
