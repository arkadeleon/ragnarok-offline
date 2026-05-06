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

    public enum Kind: Sendable {
        case miss
        case damage
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
        delay: Duration
    ) {
        self.id = UUID()
        self.creationTime = creationTime
        self.target = target
        self.amount = amount
        self.kind = amount == 0 ? .miss : .damage
        self.delay = delay
        self.duration = amount == 0 ? .milliseconds(800) : .milliseconds(1500)
    }
}
