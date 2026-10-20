//
//  ShopModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import RagnarokDatabase

final class ShopModel {
    let shopNPC: ShopNPC
    let npc: NPCModel
    let map: MapModel

    init(shopNPC: ShopNPC, npc: NPCModel, map: MapModel) {
        self.shopNPC = shopNPC
        self.npc = npc
        self.map = map
    }
}

extension ShopModel: Equatable {
    static func == (lhs: ShopModel, rhs: ShopModel) -> Bool {
        lhs.shopNPC.npcName == rhs.shopNPC.npcName
    }
}

extension ShopModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(shopNPC.npcName)
    }
}

extension ShopModel: Identifiable {
    var id: String {
        shopNPC.npcName
    }
}
