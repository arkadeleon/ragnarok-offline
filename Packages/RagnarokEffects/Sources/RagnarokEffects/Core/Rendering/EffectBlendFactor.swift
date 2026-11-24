//
//  EffectBlendFactor.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Metal

/// Direct3D 9 blend factor (`D3DBLEND` `1...15`) mapped to Metal `MTLBlendFactor`.
public enum EffectBlendFactor: Int32, Hashable, Sendable, CaseIterable {
    case zero = 1
    case one = 2
    case sourceColor = 3
    case oneMinusSourceColor = 4
    case sourceAlpha = 5
    case oneMinusSourceAlpha = 6
    case destinationAlpha = 7
    case oneMinusDestinationAlpha = 8
    case destinationColor = 9
    case oneMinusDestinationColor = 10
    case sourceAlphaSaturated = 11
    case bothSourceAlpha = 12
    case bothOneMinusSourceAlpha = 13
    case blendFactor = 14
    case oneMinusBlendFactor = 15

    public var mtlBlendFactor: MTLBlendFactor {
        switch self {
        case .zero: .zero
        case .one: .one
        case .sourceColor: .sourceColor
        case .oneMinusSourceColor: .oneMinusSourceColor
        case .sourceAlpha: .sourceAlpha
        case .oneMinusSourceAlpha: .oneMinusSourceAlpha
        case .destinationAlpha: .destinationAlpha
        case .oneMinusDestinationAlpha: .oneMinusDestinationAlpha
        case .destinationColor: .destinationColor
        case .oneMinusDestinationColor: .oneMinusDestinationColor
        case .sourceAlphaSaturated: .sourceAlphaSaturated
        case .bothSourceAlpha: .sourceAlpha
        case .bothOneMinusSourceAlpha: .oneMinusSourceAlpha
        case .blendFactor: .blendColor
        case .oneMinusBlendFactor: .oneMinusBlendColor
        }
    }

    public var isAdditiveDestination: Bool {
        self == .one
    }

    public init(d3dBlend: Int32) {
        self = Self(rawValue: d3dBlend) ?? .sourceAlpha
    }
}
