//
//  CombatText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/31.
//

import Foundation

struct CombatText: Identifiable, Sendable {
    struct Target: Sendable {
        let objectID: GameObjectID
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

    let id: UUID
    let creationTime: ContinuousClock.Instant
    let target: CombatText.Target
    let amount: Int
    let kind: CombatText.Kind
    let delay: Duration
    let duration: Duration

    var startTime: ContinuousClock.Instant {
        creationTime + delay
    }

    init(
        creationTime: ContinuousClock.Instant,
        target: CombatText.Target,
        amount: Int,
        kind: CombatText.Kind? = nil,
        delay: Duration
    ) {
        self.id = UUID()
        self.creationTime = creationTime
        self.target = target
        self.amount = amount
        self.kind = kind ?? (amount == 0 ? .miss : .damage)
        self.delay = delay
        self.duration = switch self.kind {
        case .hpRecovery, .spRecovery, .damage:
            .milliseconds(1500)
        case .miss:
            .milliseconds(800)
        case .combo, .finalCombo:
            .milliseconds(3000)
        }
    }

    func isExpired(at time: ContinuousClock.Instant) -> Bool {
        time - startTime > duration + .seconds(1)
    }
}
