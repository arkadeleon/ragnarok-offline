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

        public init(
            count: Int = 1,
            interval: TimeInterval = 0.2,
            delayOffsetDelta: TimeInterval = 0,
            delayLateDelta: TimeInterval = 0,
            alphaMaxDelta: Float = 0,
            sizeDelta: Float = 0,
            rotationDelayDelta: TimeInterval = 0
        ) {
            self.count = count
            self.interval = interval
            self.delayOffsetDelta = delayOffsetDelta
            self.delayLateDelta = delayLateDelta
            self.alphaMaxDelta = alphaMaxDelta
            self.sizeDelta = sizeDelta
            self.rotationDelayDelta = rotationDelayDelta
        }
    }
}
