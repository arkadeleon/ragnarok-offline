//
//  MetalObjectPresentation.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import simd

@MainActor
public final class MetalObjectPresentation {
    public var worldPosition: SIMD3<Float>

    init(worldPosition: SIMD3<Float>) {
        self.worldPosition = worldPosition
    }
}
