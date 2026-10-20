//
//  SkillDatabaseFilter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokConstants

struct SkillDatabaseFilter: Equatable {
    var type: BattleFlag?

    var availableTypes: [BattleFlag] {
        [.none, .weapon, .magic, .misc]
    }

    var targetType: SkillInfoFlag?

    var availableTargetTypes: [SkillInfoFlag] {
        [.passive, .attack, ._self, .ground, .support, .trap]
    }

    var isEmpty: Bool {
        type == nil &&
        targetType == nil
    }

    func isIncluded(_ skill: SkillModel) -> Bool {
        if let type, skill.type != type {
            return false
        }

        if let targetType, skill.targetType != targetType {
            return false
        }

        return true
    }

    mutating func toggleType(_ type: BattleFlag) {
        self.type = self.type == type ? nil : type
    }

    mutating func toggleTargetType(_ targetType: SkillInfoFlag) {
        self.targetType = self.targetType == targetType ? nil : targetType
    }

    mutating func reset() {
        type = nil
        targetType = nil
    }
}
