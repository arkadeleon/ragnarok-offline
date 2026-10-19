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

    /// `nil` for a floating duplicate.
    public var mapName: String?

    public var x: Int?

    public var y: Int?

    public var facing: Int?

    public var label: String

    public var npcName: String

    /// A sprite ID, e.g. `105`, or a sprite constant, e.g. `4_M_TELEPORTER`. `nil` for a warp duplicate.
    public var sprite: String?

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        if w1 != "-" {
            let column1 = w1.split(separator: ",")
            mapName = String(column1[0])
            x = column1.count > 1 ? Int(column1[1]) : nil
            y = column1.count > 2 ? Int(column1[2]) : nil
            facing = column1.count > 3 ? Int(column1[3]) : nil
        }

        label = w2.replacingOccurrences(of: "duplicate", with: "")
            .trimmingCharacters(in: CharacterSet(["(", ")"]))

        npcName = w3

        let column4 = w4.prefix(while: { !$0.isWhitespace }).split(separator: ",")
        sprite = column4.count == 2 ? nil : column4.first.map(String.init)
    }
}
