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
    case str(STREffectDefinition)
}

extension EffectDefinition {
    public var soundName: String? {
        switch self {
        case .`3D`(let definition):
            definition.soundName
        case .cylinder(let definition):
            definition.soundName
        case .str(let definition):
            definition.soundName
        }
    }

    public var assetKey: String {
        switch self {
        case .`3D`(let definition):
            "3d:\(definition.primaryAssetName)"
        case .cylinder(let definition):
            "cylinder:\(definition.textureName)"
        case .str(let definition):
            "str:\(definition.fileName)"
        }
    }

    public func resolved() -> EffectDefinition {
        switch self {
        case .`3D`(let definition):
            .`3D`(definition.resolved())
        case .cylinder(let definition):
            .cylinder(definition.resolved())
        case .str(let definition):
            .str(definition.resolved())
        }
    }
}
