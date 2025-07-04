//
//  ObservableSkill.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import RODatabase
import RORendering
import ROResources

@Observable
@dynamicMemberLookup
class ObservableSkill {
    private let mode: DatabaseMode
    private let skill: Skill

    private let localizedName: String?

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

    init(mode: DatabaseMode, skill: Skill) async {
        self.mode = mode
        self.skill = skill

        self.localizedName = await ResourceManager.shared.scriptManager().localizedSkillName(forSkillID: skill.id)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Skill, Value>) -> Value {
        skill[keyPath: keyPath]
    }

    @MainActor
    func fetchIconImage() async {
        if iconImage == nil {
            let scriptManager = await ResourceManager.shared.scriptManager()
            let pathGenerator = ResourcePathGenerator(scriptManager: scriptManager)
            let path = pathGenerator.generateSkillIconImagePath(skillAegisName: skill.aegisName)
            iconImage = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
        }
    }

    @MainActor
    func fetchDetail() async {
        localizedDescription = await ResourceManager.shared.scriptManager().localizedSkillDescription(forSkillID: skill.id)
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
