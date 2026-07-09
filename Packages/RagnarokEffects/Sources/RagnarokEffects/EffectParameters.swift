//
//  EffectParameters.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/6/30.
//

import Foundation

public enum EffectParameters {
    public struct Duplicate: Sendable {
        public var count: Int
        public var interval: TimeInterval
        public var delayOffsetDelta: TimeInterval
        public var delayLateDelta: TimeInterval
        public var alphaMaxDelta: Float
        public var sizeDelta: Float
        public var rotationDelayDelta: TimeInterval
        public var angleDelta: Float

        public init(
            count: Int = 1,
            interval: TimeInterval = 0,
            delayOffsetDelta: TimeInterval = 0,
            delayLateDelta: TimeInterval = 0,
            alphaMaxDelta: Float = 0,
            sizeDelta: Float = 0,
            rotationDelayDelta: TimeInterval = 0,
            angleDelta: Float = 0
        ) {
            self.count = count
            self.interval = interval
            self.delayOffsetDelta = delayOffsetDelta
            self.delayLateDelta = delayLateDelta
            self.alphaMaxDelta = alphaMaxDelta
            self.sizeDelta = sizeDelta
            self.rotationDelayDelta = rotationDelayDelta
            self.angleDelta = angleDelta
        }
    }

    public enum BlendMode: Int, Sendable {
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

    public enum Animation: Int, Sendable {
        case growHeight = 1
        case growTopRadius = 2
        case shrinkRadius = 3
        case growRadius = 4
        case growThenShrinkHeight = 5
    }
}
