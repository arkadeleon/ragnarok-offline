//
//  Records+Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/11.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

extension Records {

    struct Item: Record {

        var recordID: String {
            let id = "$(id)"
            return "Item#\(id)"
        }

        var recordName: String {
            let name = "$(name_english)"
            switch type {
            case "Weapon", "Armor":
                let slots: String? = "$(slots)"
                return "\(name) [\(slots ?? "0")]"
            default:
                return "\(name)"
            }
        }

        var recordFields: [RecordField] {
            return [
                RecordField(name: Strings.itemType, value: .string(type)),
                RecordField(name: Strings.itemClass, value: .string(subtype)),
                RecordField(name: Strings.itemBuy, value: .string(buy)),
                RecordField(name: Strings.itemSell, value: .string(sell))
            ]
        }
    }
}

extension Records.Item {

    var type: String {
        return "$(type)"
    }

    var subtype: String {
        return "$(subtype)"
    }

    var buy: String {
        return "$(price_buy)"
    }

    var sell: String {
        return "$(price_sell)"
    }
}
