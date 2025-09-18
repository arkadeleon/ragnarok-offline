//
//  ShopNPC.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/3/8.
//

/// Define a shop/cashshop/itemshop/pointshop NPC.
///
/// `-%TAB%shop%TAB%<NPC Name>%TAB%<sprite id>{,discount},<itemid>:<price>{,<itemid>:<price>...}`
/// `<map name>,<x>,<y>,<facing>%TAB%shop%TAB%<NPC Name>%TAB%<sprite id>{,discount},<itemid>:<price>{,<itemid>:<price>...}`
///
/// `-%TAB%cashshop%TAB%<NPC Name>%TAB%<sprite id>,<itemid>:<price>{,<itemid>:<price>...}`
/// `<map name>,<x>,<y>,<facing>%TAB%cashshop%TAB%<NPC Name>%TAB%<sprite id>,<itemid>:<price>{,<itemid>:<price>...}`
///
/// `-%TAB%itemshop%TAB%<NPC Name>%TAB%<sprite id>,<costitemid>{:<discount>},<itemid>:<price>{,<itemid>:<price>...}`
/// `<map name>,<x>,<y>,<facing>%TAB%itemshop%TAB%<NPC Name>%TAB%<sprite id>,<costitemid>{:<discount>},<itemid>:<price>{,<itemid>:<price>...}`
///
/// `-%TAB%pointshop%TAB%<NPC Name>%TAB%<sprite id>,<costvariable>{:<discount>},<itemid>:<price>{,<itemid>:<price>...}`
/// `<map name>,<x>,<y>,<facing>%TAB%pointshop%TAB%<NPC Name>%TAB%<sprite id>,<costvariable>{:<discount>},<itemid>:<price>{,<itemid>:<price>...}`
///
/// `<map name>,<x>,<y>,<facing>%TAB%marketshop%TAB%<NPC Name>%TAB%<sprite id>,<itemid>:<price>:<stock>{,<itemid>:<price>:<stock>...}`
public struct ShopNPC: Sendable {

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
    }
}
