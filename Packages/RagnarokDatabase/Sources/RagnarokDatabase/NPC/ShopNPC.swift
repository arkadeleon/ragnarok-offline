//
//  ShopNPC.swift
//  RagnarokDatabase
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
    public enum ShopType: String, Sendable {
        case shop
        case cashshop
        case itemshop
        case pointshop
        case marketshop
    }

    public struct Item: Sendable {
        public var itemID: Int

        /// The price in zeny for a shop or marketshop, in cash points for a cashshop, in the cost item
        /// for an itemshop, and in the cost variable for a pointshop. A negative price means the buy
        /// price of the item in a shop or marketshop, and 0 in other shops.
        public var price: Int

        /// The stock of a marketshop item. `nil` for other shop types.
        public var stock: Int?
    }

    /// `nil` for a floating shop, which a script opens with `callshop`.
    public var mapName: String?

    public var x: Int?

    public var y: Int?

    public var facing: Int?

    public var shopType: ShopNPC.ShopType

    public var npcName: String

    public var sprite: String

    public var items: [ShopNPC.Item]

    init(_ w1: String, _ w2: String, _ w3: String, _ w4: String) {
        if w1 != "-" {
            let column1 = w1.split(separator: ",")
            mapName = String(column1[0])
            x = column1.count > 1 ? Int(column1[1]) : nil
            y = column1.count > 2 ? Int(column1[2]) : nil
            facing = column1.count > 3 ? Int(column1[3]) : nil
        }

        shopType = ShopNPC.ShopType(rawValue: w2.lowercased()) ?? .shop

        npcName = w3

        let column4 = w4.split(separator: ",")
        sprite = String(column4[0])

        var itemColumns = column4.dropFirst()
        if shopType == .itemshop || shopType == .pointshop {
            itemColumns = itemColumns.dropFirst()
        }

        // The optional discount column of a shop has no `:`, so it is skipped here.
        items = itemColumns.compactMap { column in
            let values = column.split(separator: ":")
            guard values.count >= 2, let itemID = Int(values[0]), let price = Int(values[1]) else {
                return nil
            }
            let stock = values.count > 2 ? Int(values[2]) : nil
            return ShopNPC.Item(itemID: itemID, price: price, stock: stock)
        }
    }
}
