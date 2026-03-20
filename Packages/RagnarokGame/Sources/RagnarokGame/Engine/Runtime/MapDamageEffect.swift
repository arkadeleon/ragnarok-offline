//
//  MapDamageEffect.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Foundation

public struct MapDamageEffect: Identifiable, Sendable {
    public let id: UUID
    public var targetObjectID: UInt32
    public var amount: Int
    public var delay: TimeInterval

    public init(id: UUID = UUID(), targetObjectID: UInt32, amount: Int, delay: TimeInterval) {
        self.id = id
        self.targetObjectID = targetObjectID
        self.amount = amount
        self.delay = delay
    }
}
