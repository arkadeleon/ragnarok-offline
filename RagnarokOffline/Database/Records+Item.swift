//
//  Records+Item.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/11.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

extension Records {

    struct Item: Record {

        private let row: Row

        init(from row: Row) {
            self.row = row
        }

        var id: String {
            let id = Expression<String>("id")
            return "Item#\(row[id])"
        }

        var name: String {
            let name = Expression<String>("name_english")
            switch type {
            case "Weapon", "Armor":
                let slots = Expression<String?>("slots")
                return "\(row[name]) [\(row[slots] ?? "0")]"
            default:
                return "\(row[name])"
            }
        }

        var fields: [RecordField] {
            return [
                RecordField(name: R.string.type, value: .string(type)),
                RecordField(name: R.string.class, value: .string(subtype)),
                RecordField(name: R.string.buy, value: .string(buy)),
                RecordField(name: R.string.sell, value: .string(sell))
            ]
        }
    }
}

private extension Records.Item {

    var type: String {
        let type = Expression<String>("type")
        return row[type]
    }

    var subtype: String {
        let type = Expression<String?>("subtype")
        return row[type] ?? ""
    }

    var buy: String {
        let buy = Expression<String?>("price_buy")
        return row[buy] ?? ""
    }

    var sell: String {
        let sell = Expression<String?>("price_sell")
        return row[sell] ?? ""
    }
}
