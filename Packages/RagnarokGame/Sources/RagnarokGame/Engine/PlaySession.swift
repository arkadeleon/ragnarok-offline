//
//  PlaySession.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/28.
//

import Observation
import RagnarokModels

@MainActor
@Observable
final class PlaySession {
    var playerStatus: CharacterStatus
    var inventory: Inventory
    var skillList: SkillList
    var skillCooldowns: [Int : SkillCooldown]
    var statusChanges: [StatusChange]
    var shortcutList: ShortcutList
    let messageCenter: MessageCenter

    var dialog: NPCDialog?
    var dealSelectionNPCID: UInt32?
    var npcShop: NPCShop?
    var storage: Storage?
    var warpList: WarpList?

    var interactionMode: GameInteractionMode = .direct

    init(context: GameContext, playerStatus: CharacterStatus = CharacterStatus()) {
        self.playerStatus = playerStatus
        self.inventory = Inventory()
        self.skillList = SkillList()
        self.skillCooldowns = [:]
        self.statusChanges = []
        self.shortcutList = ShortcutList()
        self.messageCenter = MessageCenter(
            itemInfoTable: context.itemInfoTable,
            messageStringTable: context.messageStringTable
        )
    }

    /// Keeps the current cooldown when it would end later than the new one.
    func setSkillCooldown(_ cooldown: SkillCooldown) {
        if let current = skillCooldowns[cooldown.skillID], current.endTime >= cooldown.endTime {
            return
        }
        skillCooldowns[cooldown.skillID] = cooldown
    }

    /// Puts every skill in the shortcut list on cooldown, such as after a skill with a cast delay.
    func setGlobalSkillCooldown(startTime: ContinuousClock.Instant, duration: Duration) {
        for shortcut in shortcutList.rows.joined() {
            if case .skill(let skillID, _) = shortcut {
                let cooldown = SkillCooldown(skillID: skillID, startTime: startTime, duration: duration)
                setSkillCooldown(cooldown)
            }
        }
    }

    /// A status which is already active keeps its place in the list.
    func setStatusChange(_ statusChange: StatusChange) {
        if let index = statusChanges.firstIndex(where: { $0.statusID == statusChange.statusID }) {
            statusChanges[index] = statusChange
        } else {
            statusChanges.append(statusChange)
        }
    }

    func removeStatusChange(statusID: Int) {
        statusChanges.removeAll(where: { $0.statusID == statusID })
    }
}

extension PlaySession {
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

extension PlaySession {
    static let testing = PlaySession(context: .testing)
}
