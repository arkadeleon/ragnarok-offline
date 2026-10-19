//
//  FloatingNPC.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/4/2.
//

/// Define a floating NPC object.
///
/// `-%TAB%script%TAB%<NPC Name>%TAB%-1,{<code>}`
/// `-%TAB%script%TAB%<NPC Name>%TAB%<sprite id>,{<code>}`
/// `-%TAB%script%TAB%<NPC Name>%TAB%<sprite id>,<triggerX>,<triggerY>,{<code>}`
public struct FloatingNPC: Sendable {

    public var npcName: String

    /// A sprite ID, e.g. `-1`, or a sprite constant, e.g. `HIDDEN_NPC`.
    public var sprite: String

    public var code: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        npcName = w3

        sprite = String(w4.prefix(while: { $0 != "," && !$0.isWhitespace }))

        code = w4.firstIndex(of: "{").map({ String(w4[$0...]) }) ?? ""
    }
}
