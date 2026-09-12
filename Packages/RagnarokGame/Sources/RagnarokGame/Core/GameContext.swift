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
    let mapNameTable: MapNameTable
    let messageStringTable: MessageStringTable
    let skillInfoTable: SkillInfoTable

    var playerStatus: CharacterStatus
    var inventory: Inventory
    var skillList: SkillList
    var shortcutList: ShortcutList
    let messageCenter: MessageCenter

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager

        self.itemInfoTable = ItemInfoTable()
        self.mapNameTable = MapNameTable()
        self.messageStringTable = MessageStringTable()
        self.skillInfoTable = SkillInfoTable()

        self.playerStatus = CharacterStatus()
        self.inventory = Inventory()
        self.skillList = SkillList()
        self.shortcutList = ShortcutList()
        self.messageCenter = MessageCenter(
            itemInfoTable: itemInfoTable,
            messageStringTable: messageStringTable
        )
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
}

extension GameContext {
    static let testing = GameContext(resourceManager: .testing)
}
