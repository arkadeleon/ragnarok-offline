//
//  EffectBlendMode.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/29.
//

public enum EffectBlendMode: Int, Sendable {
    case zero = 1
    case one = 2
    case sourceColor = 3
    case oneMinusSourceColor = 4
    case destinationColor = 5
    case oneMinusDestinationColor = 6
    case sourceAlpha = 7
    case oneMinusSourceAlpha = 8
    case destinationAlpha = 9
    case oneMinusDestinationAlpha = 10
    case constantColor = 11
    case oneMinusConstantColor = 12
    case constantAlpha = 13
    case oneMinusConstantAlpha = 14
    case sourceAlphaSaturated = 15
}
