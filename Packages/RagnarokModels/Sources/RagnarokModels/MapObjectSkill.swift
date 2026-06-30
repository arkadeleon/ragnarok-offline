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

    public var isHealingSkill: Bool {
        switch skillID {
        case .al_heal, .ab_highnessheal, .ab_cheal:
            true
        default:
            false
        }
    }

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

    public init(from packet: PACKET_ZC_USE_SKILL) {
        self.skillID = SkillID(rawValue: Int(packet.SKID))
        self.sourceObjectID = packet.srcAID
        self.targetObjectID = packet.targetAID
        self.attackDelay = 0
        self.damage = -1
        self.level = Int(packet.level)
        self.count = 1
        self.damageType = .normal
    }
}
