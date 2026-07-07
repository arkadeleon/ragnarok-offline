//
//  EffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import simd

public enum EffectDefinition: Sendable {
    case `3D`(Effect3DDefinition)
    case cylinder(CylinderEffectDefinition)
    case spr(SPREffectDefinition)
    case str(STREffectDefinition)
}

extension EffectDefinition {
    public func resolved() -> EffectDefinition {
        switch self {
        case .`3D`(let definition):
            .`3D`(definition.resolved())
        case .cylinder(let definition):
            .cylinder(definition.resolved())
        case .spr(let definition):
            .spr(definition)
        case .str(let definition):
            .str(definition.resolved())
        }
    }
}
