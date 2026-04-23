//
//  MapDamageEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation

public struct MapDamageEffect: Identifiable, Sendable {
    public let id: UUID
    public let creationTime: ContinuousClock.Instant
    public var targetObjectID: GameObjectID
    public var amount: Int
    public var delay: Duration

    public init(
        id: UUID = UUID(),
        creationTime: ContinuousClock.Instant = .now,
        targetObjectID: GameObjectID,
        amount: Int,
        delay: Duration
    ) {
        self.id = id
        self.creationTime = creationTime
        self.targetObjectID = targetObjectID
        self.amount = amount
        self.delay = delay
    }

    func isExpired(at now: ContinuousClock.Instant) -> Bool {
        let animationDuration: Duration = amount == 0 ? .milliseconds(800) : .milliseconds(1500)
        return now - creationTime > delay + animationDuration + .seconds(1)
    }
}
