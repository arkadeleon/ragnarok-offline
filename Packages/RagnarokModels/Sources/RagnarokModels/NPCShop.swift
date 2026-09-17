//
//  NPCShop.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/16.
//

import RagnarokConstants
import RagnarokPackets

public enum NPCShopDealType: UInt8, Sendable {
    case buy = 0
    case sell = 1
}

public struct NPCShopBuyItem: Hashable, Sendable {
    public let itemID: Int
    public let price: Int
    public let discountPrice: Int
    public let type: ItemType
    public let location: EquipPositions

    public var unitPrice: Int {
        discountPrice > 0 ? discountPrice : price
    }

    public init(itemID: Int, price: Int, discountPrice: Int, type: ItemType, location: EquipPositions) {
        self.itemID = itemID
        self.price = price
        self.discountPrice = discountPrice
        self.type = type
        self.location = location
    }

    public init(from item: PACKET_ZC_PC_PURCHASE_ITEMLIST_sub) {
        self.itemID = Int(item.itemId)
        self.price = Int(item.price)
        self.discountPrice = Int(item.discountPrice)
        self.type = ItemType(rawValue: Int(item.itemType)) ?? .etc
        self.location = EquipPositions(rawValue: Int(item.location))
    }
}

public struct NPCShopSellItem: Hashable, Sendable {
    public let index: Int
    public let price: Int
    public let overcharge: Int

    public var unitPrice: Int {
        overcharge > 0 ? overcharge : price
    }

    public init(index: Int, price: Int, overcharge: Int) {
        self.index = index
        self.price = price
        self.overcharge = overcharge
    }

    public init(from item: PACKET_ZC_PC_SELL_ITEMLIST_sub) {
        self.index = Int(item.index)
        self.price = Int(item.price)
        self.overcharge = Int(item.overcharge)
    }
}

public enum NPCShop: Equatable, Sendable {
    case buy([NPCShopBuyItem])
    case sell([NPCShopSellItem])

    public init(from packet: PACKET_ZC_PC_PURCHASE_ITEMLIST) {
        self = .buy(packet.items.map(NPCShopBuyItem.init))
    }

    public init(from packet: PACKET_ZC_PC_SELL_ITEMLIST) {
        self = .sell(packet.items.map(NPCShopSellItem.init))
    }
}

public struct NPCShopPurchase: Sendable {
    public let itemID: Int
    public let amount: Int

    public init(itemID: Int, amount: Int) {
        self.itemID = itemID
        self.amount = amount
    }
}

public struct NPCShopSale: Sendable {
    public let index: Int
    public let amount: Int

    public init(index: Int, amount: Int) {
        self.index = index
        self.amount = amount
    }
}
