//
//  MapCombatText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation

public struct MapCombatText: Identifiable, Sendable {
    public struct Target: Sendable {
        public let id: GameObjectID
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
    public let target: MapCombatText.Target
    public let amount: Int
    public let kind: MapCombatText.Kind
    public let delay: Duration
    public let duration: Duration

    public init(
        creationTime: ContinuousClock.Instant,
        target: MapCombatText.Target,
        amount: Int,
        kind: MapCombatText.Kind? = nil,
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
