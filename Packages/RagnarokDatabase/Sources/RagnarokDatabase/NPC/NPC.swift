//
//  NPC.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/9.
//

/// Define an NPC object.
///
/// `<map name>,<x>,<y>,<facing>%TAB%script%TAB%<NPC Name>%TAB%<sprite id>,{<code>}`
/// `<map name>,<x>,<y>,<facing>%TAB%script%TAB%<NPC Name>%TAB%<sprite id>,<triggerX>,<triggerY>,{<code>}`
/// `<map name>,<x>,<y>,<facing>%TAB%script(<state>)%TAB%<NPC Name>%TAB%<sprite id>,{<code>}`
/// `<map name>,<x>,<y>,<facing>%TAB%script(<state>)%TAB%<NPC Name>%TAB%<sprite id>,<triggerX>,<triggerY>,{<code>}`
public struct NPC: Sendable {

    public var mapName: String

    public var x: Int?

    public var y: Int?

    public var facing: Int?

    public var npcName: String

    /// A sprite ID, e.g. `105`, or a sprite constant, e.g. `4_M_TELEPORTER`.
    public var sprite: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        let column1 = w1.split(separator: ",")
        mapName = String(column1[0])
        x = column1.count > 1 ? Int(column1[1]) : nil
        y = column1.count > 2 ? Int(column1[2]) : nil
        facing = column1.count > 3 ? Int(column1[3]) : nil

        npcName = w3

        sprite = String(w4.prefix(while: { $0 != "," && !$0.isWhitespace }))
    }
}
