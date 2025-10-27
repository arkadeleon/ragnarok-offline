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

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
    }
}
