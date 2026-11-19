//
//  SkillCooldown.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/10/14.
//

import Foundation
import RagnarokPackets

public struct SkillCooldown: Sendable {
    public let skillID: Int
    public let startTime: TimeInterval
    public let duration: TimeInterval

    public var endTime: TimeInterval {
        startTime + duration
    }

    public init(skillID: Int, startTime: TimeInterval, duration: TimeInterval) {
        self.skillID = skillID
        self.startTime = startTime
        self.duration = duration
    }

    public init(from packet: PACKET_ZC_SKILL_POSTDELAY, startTime: TimeInterval) {
        self.skillID = Int(packet.SKID)
        self.startTime = startTime
        self.duration = TimeInterval(packet.DelayTM) / 1000
    }
}
