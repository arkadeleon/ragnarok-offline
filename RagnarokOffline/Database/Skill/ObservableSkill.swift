//
//  ObservableSkill.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import ROClientResources
import RODatabase
import ROLocalizations

@Observable
@dynamicMemberLookup
class ObservableSkill {
    private let mode: DatabaseMode
    private let skill: Skill

    var localizedName: String?
    var iconImage: CGImage?
    var localizedDescription: String?

    var displayName: String {
        localizedName ?? skill.name
    }

    var spCost: String {
        guard let spCost = skill.requires?.spCost else {
            return ""
        }

        switch spCost {
        case .left(let spCost):
            return spCost.formatted()
        case .right(let spCost):
            return spCost.compactMap(String.init).joined(separator: " / ")
        }
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "ID", value: "#\(skill.id)"))
        attributes.append(.init(name: "Aegis Name", value: skill.aegisName))
        attributes.append(.init(name: "Name", value: skill.name))
        attributes.append(.init(name: "Maximum Level", value: skill.maxLevel))
        attributes.append(.init(name: "Type", value: skill.type.stringValue))
        attributes.append(.init(name: "Target Type", value: skill.targetType.stringValue))

        return attributes
    }

    init(mode: DatabaseMode, skill: Skill) {
        self.mode = mode
        self.skill = skill
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Skill, Value>) -> Value {
        skill[keyPath: keyPath]
    }

    func fetchLocalizedName() {
        localizedName = SkillInfoTable.shared.localizedSkillName(forSkillID: skill.id)
    }

    func fetchIconImage() async {
        iconImage = await ClientResourceManager.default.skillIconImage(forSkillAegisName: skill.aegisName)
    }

    func fetchDetail() {
        localizedDescription = SkillInfoTable.shared.localizedSkillDescription(forSkillID: skill.id)
    }
}

extension ObservableSkill: Hashable {
    static func == (lhs: ObservableSkill, rhs: ObservableSkill) -> Bool {
        lhs.skill.id == rhs.skill.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(skill.id)
    }
}

extension ObservableSkill: Identifiable {
    var id: Int {
        skill.id
    }
}