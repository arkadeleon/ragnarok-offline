//
//  SkillModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Foundation
import Observation
import RagnarokDatabase
import RagnarokResources

@Observable
@dynamicMemberLookup
final class SkillModel {
    private let mode: DatabaseMode
    private let skill: Skill
    private let resourceManager: ResourceManager

    let localizedName: String?
    let localizedDescription: String?

    var iconImage: Resources.Image?

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
            return spCost.map({ $0.formatted() }).joined(separator: " / ")
        }
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("ID", table: "Database"), value: "#\(skill.id)"))
        attributes.append(.init(name: LocalizedStringResource("Aegis Name", table: "Database"), value: skill.aegisName))
        attributes.append(.init(name: LocalizedStringResource("Name", table: "Database"), value: skill.name))
        attributes.append(.init(name: LocalizedStringResource("Maximum Level", table: "Database"), value: skill.maxLevel))
        attributes.append(.init(name: LocalizedStringResource("Type", table: "Database"), value: skill.type.localizedName))
        attributes.append(.init(name: LocalizedStringResource("Target Type", table: "Database"), value: skill.targetType.localizedName))

        return attributes
    }

    init(mode: DatabaseMode, skill: Skill, localizedName: String?, localizedDescription: String?, resourceManager: ResourceManager) {
        self.mode = mode
        self.skill = skill
        self.localizedName = localizedName
        self.localizedDescription = localizedDescription
        self.resourceManager = resourceManager
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Skill, Value>) -> Value {
        skill[keyPath: keyPath]
    }

    @MainActor
    func fetchIconImage() async {
        if iconImage == nil {
            let path = ResourcePath.generateSkillIconImagePath(skillAegisName: skill.aegisName)
            iconImage = try? await resourceManager.image(at: path, removesMagentaPixels: true)
        }
    }
}

extension SkillModel: Equatable {
    static func == (lhs: SkillModel, rhs: SkillModel) -> Bool {
        lhs.skill.id == rhs.skill.id
    }
}

extension SkillModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(skill.id)
    }
}

extension SkillModel: Identifiable {
    var id: Int {
        skill.id
    }
}

extension SkillModel {
    struct SkillLevel: Identifiable {
        var level: Int
        var spCost: Int
        var castTime: Int
        var fixedCastTime: Int
        var afterCastActDelay: Int
        var cooldown: Int
        var range: Int

        var id: Int {
            level
        }
    }

    var levels: [SkillLevel] {
        (1...max(skill.maxLevel, 1)).map { level in
            SkillLevel(
                level: level,
                spCost: skill.requires?.spCost.value(forLevel: level) ?? 0,
                castTime: skill.castTime.value(forLevel: level),
                fixedCastTime: skill.fixedCastTime.value(forLevel: level),
                afterCastActDelay: skill.afterCastActDelay.value(forLevel: level),
                cooldown: skill.cooldown.value(forLevel: level),
                range: abs(skill.range.value(forLevel: level))
            )
        }
    }

    var showsSPCost: Bool {
        skill.requires?.spCost.containsNonZeroValue ?? false
    }

    var showsCastTime: Bool {
        skill.castTime.containsNonZeroValue
    }

    var showsFixedCastTime: Bool {
        skill.fixedCastTime.containsNonZeroValue
    }

    var showsAfterCastActDelay: Bool {
        skill.afterCastActDelay.containsNonZeroValue
    }

    var showsCooldown: Bool {
        skill.cooldown.containsNonZeroValue
    }

    var showsRange: Bool {
        skill.range.containsNonZeroValue
    }
}

extension EitherNode<Int, [Int]> {
    fileprivate var containsNonZeroValue: Bool {
        switch self {
        case .left(let value):
            value != 0
        case .right(let values):
            values.contains(where: { $0 != 0 })
        }
    }

    fileprivate func value(forLevel level: Int) -> Int {
        switch self {
        case .left(let value):
            value
        case .right(let values):
            level <= values.count ? values[level - 1] : values.last ?? 0
        }
    }
}
