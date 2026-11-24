//
//  EffectBlendKey.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

public struct EffectBlendKey: Hashable, Sendable {
    public let srcBlend: EffectBlendFactor
    public let dstBlend: EffectBlendFactor

    public var isAdditive: Bool {
        dstBlend.isAdditiveDestination
    }

    public init(srcBlend: EffectBlendFactor, dstBlend: EffectBlendFactor) {
        self.srcBlend = srcBlend
        self.dstBlend = dstBlend
    }

    public init(d3dSourceBlend: Int32, d3dDestinationBlend: Int32) {
        self.srcBlend = EffectBlendFactor(d3dBlend: d3dSourceBlend)
        self.dstBlend = EffectBlendFactor(d3dBlend: d3dDestinationBlend)
    }
}
