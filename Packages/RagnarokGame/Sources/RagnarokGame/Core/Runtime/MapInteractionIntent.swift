//
//  MapInteractionIntent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import simd

public enum MapInteractionIntent: Sendable {
    case raycast(origin: SIMD3<Float>, direction: SIMD3<Float>)
}
