//
//  EffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import simd

public enum EffectDefinition: Sendable {
    case `2D`(Effect2DDefinition)
    case `3D`(Effect3DDefinition)
    case cylinder(CylinderEffectDefinition)
    case spr(SPREffectDefinition)
    case str(STREffectDefinition)
}
