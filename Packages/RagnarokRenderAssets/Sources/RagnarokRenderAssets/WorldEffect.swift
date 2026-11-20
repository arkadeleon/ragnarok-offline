//
//  WorldEffect.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/7/15.
//

import simd

public struct WorldEffect: Sendable, Hashable {
    public var effectID: Int
    public var position: SIMD3<Float>
    public var delay: Float
    public var parameters: SIMD4<Float>

    public init(
        effectID: Int,
        position: SIMD3<Float>,
        delay: Float = 0,
        parameters: SIMD4<Float> = .zero
    ) {
        self.effectID = effectID
        self.position = position
        self.delay = delay
        self.parameters = parameters
    }
}
