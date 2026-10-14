//
//  GameContext.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/6.
//

import Observation
import RagnarokLocalization
import RagnarokModels
import RagnarokResources

@MainActor
@Observable
final class GameContext {
    let resourceManager: ResourceManager

    let itemInfoTable: ItemInfoTable
    let mapInfoTable: MapInfoTable
    let messageStringTable: MessageStringTable
    let skillInfoTable: SkillInfoTable

    var playerStatus: CharacterStatus
    var inventory: Inventory
    var skillList: SkillList
    var skillCooldowns: [Int : SkillCooldown]
    var shortcutList: ShortcutList
    let messageCenter: MessageCenter

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager

        self.itemInfoTable = ItemInfoTable()
        self.mapInfoTable = MapInfoTable()
        self.messageStringTable = MessageStringTable()
        self.skillInfoTable = SkillInfoTable()

        self.playerStatus = CharacterStatus()
        self.inventory = Inventory()
        self.skillList = SkillList()
        self.skillCooldowns = [:]
        self.shortcutList = ShortcutList()
        self.messageCenter = MessageCenter(
            itemInfoTable: itemInfoTable,
            messageStringTable: messageStringTable
        )
    }

    /// Keeps the current cooldown when it would end later than the new one.
    func setSkillCooldown(_ cooldown: SkillCooldown) {
        if let current = skillCooldowns[cooldown.skillID], current.endTime >= cooldown.endTime {
            return
        }
        skillCooldowns[cooldown.skillID] = cooldown
    }
}

extension GameContext {
    /// An item which is no longer in the inventory is dimmed, and cannot be used.
    func isShortcutAvailable(_ shortcut: Shortcut) -> Bool {
        switch shortcut {
        case .empty, .skill:
            true
        case .item(let itemID):
            inventory.items.values.contains(where: { $0.itemID == itemID })
        }
    }

    /// The number shown beside the icon: how many of an item are left, or the level a skill is used at.
    func shortcutLabel(_ shortcut: Shortcut) -> String? {
        switch shortcut {
        case .empty:
            nil
        case .item(let itemID):
            inventory.items.values.first(where: { $0.itemID == itemID }).map({ "\($0.amount)" })
        case .skill(_, let level):
            "\(level)"
        }
    }

    func skillCooldown(for shortcut: Shortcut) -> SkillCooldown? {
        switch shortcut {
        case .empty, .item:
            nil
        case .skill(let skillID, _):
            skillCooldowns[skillID]
        }
    }
}

extension GameContext {
    static let testing = GameContext(resourceManager: .testing)
}
