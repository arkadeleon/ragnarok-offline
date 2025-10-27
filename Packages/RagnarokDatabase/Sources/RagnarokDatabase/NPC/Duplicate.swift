//
//  Duplicate.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/8.
//

import Foundation

/// Define an warp/shop/cashshop/itemshop/pointshop/NPC duplicate.
///
/// `warp/warp2: <map name>,<x>,<y>,<facing>%TAB%duplicate(<label>)%TAB%<NPC Name>%TAB%<spanx>,<spany>`
///
/// `shop/cashshop/itemshop/pointshop/npc: -%TAB%duplicate(<label>)%TAB%<NPC Name>%TAB%<sprite id>`
/// `shop/cashshop/itemshop/pointshop/npc: <map name>,<x>,<y>,<facing>%TAB%duplicate(<label>)%TAB%<NPC Name>%TAB%<sprite id>`
///
/// `npc: -%TAB%duplicate(<label>)%TAB%<NPC Name>%TAB%<sprite id>,<triggerX>,<triggerY>`
/// `npc: <map name>,<x>,<y>,<facing>%TAB%duplicate(<label>)%TAB%<NPC Name>%TAB%<sprite id>,<triggerX>,<triggerY>`
public struct Duplicate: Sendable {

    public var label: String

    public var npcName: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        label = w2.replacingOccurrences(of: "duplicate", with: "")
            .trimmingCharacters(in: CharacterSet(["(", ")"]))

        npcName = w3
    }
}
