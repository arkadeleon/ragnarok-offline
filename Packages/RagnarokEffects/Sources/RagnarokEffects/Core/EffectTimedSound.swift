//
//  EffectTimedSound.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/23.
//

import Foundation
import simd

public struct EffectTimedSound: Sendable, Equatable {
    public let tick: Int
    public let names: [String]
    public let chanceDenominator: Int

    public init(tick: Int, names: [String], chanceDenominator: Int = 1) {
        self.tick = tick
        self.names = names
        self.chanceDenominator = chanceDenominator
    }

    @MainActor
    public func playIfMatching(
        tick currentTick: Int,
        atWorldPosition worldPosition: SIMD3<Float>?,
        world: any EffectWorldContext
    ) {
        guard tick == currentTick else {
            return
        }
        if chanceDenominator > 1 && Int.random(in: 0..<chanceDenominator) != 0 {
            return
        }
        guard let soundName = names.count == 1 ? names.first : names.randomElement() else {
            return
        }
        world.playSound(named: soundName, atWorldPosition: worldPosition, delay: 0)
    }
}
