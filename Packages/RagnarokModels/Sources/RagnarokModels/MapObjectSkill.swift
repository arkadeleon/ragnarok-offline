//
//  MapObjectSkill.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/6/1.
//

import RagnarokConstants
import RagnarokPackets

public struct MapObjectSkill: Sendable {
    public let skillID: SkillID?
    public let sourceObjectID: UInt32
    public let targetObjectID: UInt32
    public let attackDelay: Int
    public let damage: Int
    public let level: Int
    public let count: Int
    public let damageType: DamageType

    public init(from packet: PACKET_ZC_NOTIFY_SKILL) {
        self.skillID = SkillID(rawValue: Int(packet.SKID))
        self.sourceObjectID = packet.AID
        self.targetObjectID = packet.targetID
        self.attackDelay = Int(packet.attackMT)
        self.damage = Int(packet.damage)
        self.level = Int(packet.level)
        self.count = Int(packet.count)
        self.damageType = DamageType(rawValue: Int(packet.action)) ?? .normal
    }
}
