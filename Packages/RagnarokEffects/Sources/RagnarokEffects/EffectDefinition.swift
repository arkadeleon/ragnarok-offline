//
//  EffectDefinition.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import simd

public enum EffectDefinition: Sendable {
    case `2D`(TwoDEffectDefinition)
    case `3D`(ThreeDEffectDefinition)
    case cylinder(CylinderEffectDefinition)
    case spr(SPREffectDefinition)
    case str(STREffectDefinition)
}
