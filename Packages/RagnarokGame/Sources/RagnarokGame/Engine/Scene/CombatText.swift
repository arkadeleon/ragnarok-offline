//
//  CombatText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Foundation
import simd

final class CombatText: Sendable {
    struct Target: Sendable {
        let objectID: GameObjectID
        let initialWorldPosition: SIMD3<Float>
        let isPlayer: Bool
    }

    enum Kind: Sendable, Equatable {
        case hpRecovery
        case spRecovery
        case miss
        case damage
        case combo
        case finalCombo

        var isCombo: Bool {
            self == .combo || self == .finalCombo
        }
    }

    let creationTime: TimeInterval
    let target: CombatText.Target
    let amount: Int
    let kind: CombatText.Kind
    let delay: TimeInterval

    var startTime: TimeInterval {
        creationTime + delay
    }

    var duration: TimeInterval {
        switch kind {
        case .hpRecovery, .spRecovery, .damage:
            1.5
        case .miss:
            0.8
        case .combo, .finalCombo:
            3.0
        }
    }

    init(
        creationTime: TimeInterval,
        target: CombatText.Target,
        amount: Int,
        kind: CombatText.Kind? = nil,
        delay: TimeInterval
    ) {
        self.creationTime = creationTime
        self.target = target
        self.amount = amount
        self.kind = kind ?? (amount == 0 ? .miss : .damage)
        self.delay = delay
    }

    func isExpired(atTime time: TimeInterval) -> Bool {
        time - startTime > duration + 1
    }
}
