//
//  EffectPrimitiveRenderState.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Metal
import RagnarokRendering

public enum EffectPrimitiveRenderMode: Int32, Hashable, Sendable {
    case world3D = 0
    case billboard3D = 1
    case screen2D = 2
    case screen2DAbsolute = 3
}

public struct EffectPrimitiveRenderState: Hashable, Sendable {
    public static let alpha = EffectPrimitiveRenderState()
    public static let additive = EffectPrimitiveRenderState(srcBlend: .sourceAlpha, dstBlend: .one)
    public static let pureAdditive = EffectPrimitiveRenderState(srcBlend: .one, dstBlend: .one)
    public static let inverseMask = EffectPrimitiveRenderState(srcBlend: .zero, dstBlend: .oneMinusSourceColor)

    public var srcBlend: EffectBlendFactor
    public var dstBlend: EffectBlendFactor
    public var depthTest: Bool
    public var depthWrite: Bool
    public var cullMode: MTLCullMode
    public var bucket: RenderPassBucket
    public var depthBias: Float
    public var alphaTestThreshold: Float

    public var isAdditive: Bool {
        dstBlend.isAdditiveDestination
    }

    public init(
        srcBlend: EffectBlendFactor = .sourceAlpha,
        dstBlend: EffectBlendFactor = .oneMinusSourceAlpha,
        depthTest: Bool = true,
        depthWrite: Bool = false,
        cullMode: MTLCullMode = .none,
        bucket: RenderPassBucket = .translucent,
        depthBias: Float = 0,
        alphaTestThreshold: Float = 0.001
    ) {
        self.srcBlend = srcBlend
        self.dstBlend = dstBlend
        self.depthTest = depthTest
        self.depthWrite = depthWrite
        self.cullMode = cullMode
        self.bucket = bucket
        self.depthBias = depthBias
        self.alphaTestThreshold = alphaTestThreshold
    }
}
