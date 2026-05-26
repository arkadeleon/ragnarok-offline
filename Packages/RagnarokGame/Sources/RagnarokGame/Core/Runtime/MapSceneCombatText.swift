//
//  MapSceneCombatText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation

public struct MapSceneCombatText: Identifiable, Sendable {
    public struct Target: Sendable {
        public let objectID: GameObjectID
        public let isPlayer: Bool
    }

    public enum Kind: Sendable, Equatable {
        case miss
        case damage
        case hpRecovery
        case spRecovery
    }

    public let id: UUID
    public let creationTime: ContinuousClock.Instant
    public let target: MapSceneCombatText.Target
    public let amount: Int
    public let kind: MapSceneCombatText.Kind
    public let delay: Duration
    public let duration: Duration

    public init(
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
