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
    let mapInfoTable: MapInfoTable
    let messageStringTable: MessageStringTable
    let skillInfoTable: SkillInfoTable
    let statusInfoTable: StatusInfoTable

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager

        self.itemInfoTable = ItemInfoTable()
        self.mapInfoTable = MapInfoTable()
        self.messageStringTable = MessageStringTable()
        self.skillInfoTable = SkillInfoTable()
        self.statusInfoTable = StatusInfoTable()
    }
}

extension GameContext {
    static let testing = GameContext(resourceManager: .testing)
}
