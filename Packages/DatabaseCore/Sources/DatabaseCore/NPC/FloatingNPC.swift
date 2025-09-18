//
//  FloatingNPC.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/4/2.
//

/// Define a floating NPC object.
///
/// `-%TAB%script%TAB%<NPC Name>%TAB%-1,{<code>}`
public struct FloatingNPC: Sendable {

    public var npcName: String

    public var code: String

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        npcName = w3
        code = w3
    }
}
