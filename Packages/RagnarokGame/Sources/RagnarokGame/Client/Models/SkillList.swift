//
//  SkillList.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/1.
//

import Observation
import RagnarokModels
import RagnarokPackets

@Observable
final class SkillList {
    var skills: [Int : SkillInfo] = [:]

    var sortedSkills: [SkillInfo] {
        skills.values.sorted()
    }

    var activeSkills: [SkillInfo] {
        sortedSkills.filter { skill in
            skill.level > 0 && !skill.isPassiveSkill
        }
    }

    func replace(from packet: PACKET_ZC_SKILLINFO_LIST) {
        let skills = packet.skills.map(SkillInfo.init(from:))
        self.skills = Dictionary(uniqueKeysWithValues: skills.map({ ($0.skillID, $0) }))
    }

    func add(from packet: PACKET_ZC_ADD_SKILL) {
        let skill = SkillInfo(from: packet.skill)
        skills[skill.skillID] = skill
    }

    func delete(from packet: PACKET_ZC_SKILLINFO_DELETE) {
        let skillID = Int(packet.skillID)
        skills[skillID] = nil
    }

    func update(from packet: PACKET_ZC_SKILLINFO_UPDATE) {
        let skillID = Int(packet.skillId)

        if var skill = skills[skillID] {
            skill.update(from: packet)
            skills[skillID] = skill
        }
    }

    func update(from packet: PACKET_ZC_SKILLINFO_UPDATE2) {
        let skillID = Int(packet.id)

        if var skill = skills[skillID] {
            skill.update(from: packet)
            skills[skillID] = skill
        }
    }
}
