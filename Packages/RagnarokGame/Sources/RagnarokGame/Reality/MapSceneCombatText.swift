//
//  MapSceneCombatText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation

struct MapSceneCombatText: Identifiable, Sendable {
    struct Target: Sendable {
        let objectID: GameObjectID
        let isPlayer: Bool
    }

    enum Kind: Sendable, Equatable {
        case miss
        case damage
        case hpRecovery
        case spRecovery
    }

    let id: UUID
    let creationTime: ContinuousClock.Instant
    let target: MapSceneCombatText.Target
    let amount: Int
    let kind: MapSceneCombatText.Kind
    let delay: Duration
    let duration: Duration

    init(
        creationTime: ContinuousClock.Instant,
        target: MapSceneCombatText.Target,
        amount: Int,
        kind: MapSceneCombatText.Kind? = nil,
        delay: Duration
    ) {
        self.id = UUID()
        self.creationTime = creationTime
        self.target = target
        self.amount = amount
        self.kind = kind ?? (amount == 0 ? .miss : .damage)
        self.delay = delay
        self.duration = switch self.kind {
        case .miss:
            .milliseconds(800)
        case .damage, .hpRecovery, .spRecovery:
            .milliseconds(1500)
        }
    }
}
