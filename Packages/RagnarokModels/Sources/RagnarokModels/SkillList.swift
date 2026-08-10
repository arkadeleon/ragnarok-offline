//
//  SkillList.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/3/1.
//

import RagnarokPackets

public struct SkillList {
    public var skills: [Int : SkillInfo] = [:]

    public var sortedSkills: [SkillInfo] {
        skills.values.sorted()
    }

    public var activeSkills: [SkillInfo] {
        sortedSkills.filter { skill in
            skill.level > 0 && !skill.isPassiveSkill
        }
    }

    public init() {
    }

    public mutating func replace(from packet: PACKET_ZC_SKILLINFO_LIST) {
        let skills = packet.skills.map(SkillInfo.init(from:))
        self.skills = Dictionary(uniqueKeysWithValues: skills.map({ ($0.skillID, $0) }))
    }

    public mutating func add(from packet: PACKET_ZC_ADD_SKILL) {
        let skill = SkillInfo(from: packet.skill)
        skills[skill.skillID] = skill
    }

    public mutating func delete(from packet: PACKET_ZC_SKILLINFO_DELETE) {
        let skillID = Int(packet.skillID)
        skills[skillID] = nil
    }

    public mutating func update(from packet: PACKET_ZC_SKILLINFO_UPDATE) {
        let skillID = Int(packet.skillId)

        if var skill = skills[skillID] {
            skill.update(from: packet)
            skills[skillID] = skill
        }
    }

    public mutating func update(from packet: PACKET_ZC_SKILLINFO_UPDATE2) {
        let skillID = Int(packet.id)

        if var skill = skills[skillID] {
            skill.update(from: packet)
            skills[skillID] = skill
        }
    }
}
