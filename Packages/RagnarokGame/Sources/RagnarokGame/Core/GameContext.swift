//
//  GameContext.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/6.
//

import Observation
import RagnarokLocalization
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
    let inventory: Inventory
    let skillList: SkillList
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
        self.messageCenter = MessageCenter(
            itemInfoTable: itemInfoTable,
            messageStringTable: messageStringTable
        )
    }
}

extension GameContext {
    static let testing = GameContext(resourceManager: .testing)
}
