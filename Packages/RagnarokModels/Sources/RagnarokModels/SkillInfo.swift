//
//  SkillInfo.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/3/1.
//

import RagnarokConstants
import RagnarokPackets

public struct SkillInfo: Sendable, Hashable {
    public var skillID: Int
    public var flag: Int
    public var level: Int
    public var spCost: Int
    public var attackRange: Int
    public var isUpgradable: Bool
    public var maxLevel: Int

    public init() {
        self.skillID = 0
        self.flag = 0
        self.level = 0
        self.spCost = 0
        self.attackRange = 0
        self.isUpgradable = false
        self.maxLevel = 0
    }

    public init(from skillData: SKILLDATA) {
        self.skillID = Int(skillData.id)
        self.flag = Int(skillData.inf)
        self.level = Int(skillData.level)
        self.spCost = Int(skillData.sp)
        self.attackRange = Int(skillData.range2)
        self.isUpgradable = (skillData.upFlag != 0)
        self.maxLevel = Int(skillData.level2)
    }

    public mutating func update(from packet: PACKET_ZC_SKILLINFO_UPDATE) {
        level = Int(packet.level)
        spCost = Int(packet.sp)
        attackRange = Int(packet.range2)
        isUpgradable = (packet.upFlag != 0)
    }

    public mutating func update(from packet: PACKET_ZC_SKILLINFO_UPDATE2) {
        flag = Int(packet.inf)
        level = Int(packet.level)
        spCost = Int(packet.sp)
        attackRange = Int(packet.range2)
        isUpgradable = (packet.upFlag != 0)
        maxLevel = Int(packet.level2)
    }
}

extension SkillInfo: Comparable {
    public static func < (lhs: SkillInfo, rhs: SkillInfo) -> Bool {
        lhs.skillID < rhs.skillID
    }
}
