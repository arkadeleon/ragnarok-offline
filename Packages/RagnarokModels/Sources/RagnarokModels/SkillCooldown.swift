//
//  SkillCooldown.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/10/14.
//

import RagnarokPackets

public struct SkillCooldown: Sendable {
    public let skillID: Int
    public let startTime: ContinuousClock.Instant
    public let duration: Duration

    public var endTime: ContinuousClock.Instant {
        startTime + duration
    }

    public init(from packet: PACKET_ZC_SKILL_POSTDELAY, startTime: ContinuousClock.Instant) {
        self.skillID = Int(packet.SKID)
        self.startTime = startTime
        self.duration = .milliseconds(packet.DelayTM)
    }
}
