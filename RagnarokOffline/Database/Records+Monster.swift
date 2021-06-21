//
//  Records+Monster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/11.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

extension Records {

    struct Monster: Record {

        var id: String {
            let id = "$(ID)"
            return "Monster#\(id)"
        }

        var name: String {
            return "$(iName)"
        }

        var fields: [RecordField] {
            return [
                RecordField(name: Strings.drops, value: .references(droppedItems))
            ]
        }
    }
}

extension Records.Monster {

    var droppedItems: [AnyRecord] {
        let columns: [(String?, String?)] = [
            ("$(Drop1id)", "$(Drop1per)"),
            ("$(Drop2id)", "$(Drop2per)"),
            ("$(Drop3id)", "$(Drop3per)"),
            ("$(Drop4id)", "$(Drop4per)"),
            ("$(Drop5id)", "$(Drop5per)"),
            ("$(Drop6id)", "$(Drop6per)"),
            ("$(Drop7id)", "$(Drop7per)"),
            ("$(Drop8id)", "$(Drop8per)"),
            ("$(Drop9id)", "$(Drop9per)")
        ]

        var droppedItems: [AnyRecord] = []
        for column in columns {
            guard let dropId = column.0, let dropPer = column.1 else {
                continue
            }

            guard let dropRate = Double(dropPer) else {
                continue
            }

            guard let item = Database.shared.fetchItems(with: { $0.id == dropId }).first else {
                continue
            }

            let droppedItem = Records.DroppedItem(item: item, dropRate: dropRate / 100)
            let record = AnyRecord(droppedItem)
            droppedItems.append(record)
        }

        return droppedItems
    }
}
