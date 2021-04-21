//
//  Records+Monster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/11.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

extension Records {

    struct Monster: Record {

        private let row: Row

        init(from row: Row) {
            self.row = row
        }

        var id: String {
            let id = Expression<String>("ID")
            return "Monster#\(row[id])"
        }

        var name: String {
            let name = Expression<String>("iName")
            return row[name]
        }

        var fields: [RecordField] {
            return [
                RecordField(name: Strings.drops, value: .references(droppedItems))
            ]
        }
    }
}

private extension Records.Monster {

    var droppedItems: [AnyRecord] {
        let columns = [
            (Expression<String?>("Drop1id"), Expression<String?>("Drop1per")),
            (Expression<String?>("Drop2id"), Expression<String?>("Drop2per")),
            (Expression<String?>("Drop3id"), Expression<String?>("Drop3per")),
            (Expression<String?>("Drop4id"), Expression<String?>("Drop4per")),
            (Expression<String?>("Drop5id"), Expression<String?>("Drop5per")),
            (Expression<String?>("Drop6id"), Expression<String?>("Drop6per")),
            (Expression<String?>("Drop7id"), Expression<String?>("Drop7per")),
            (Expression<String?>("Drop8id"), Expression<String?>("Drop8per")),
            (Expression<String?>("Drop9id"), Expression<String?>("Drop9per"))
        ]

        var droppedItems: [AnyRecord] = []
        for column in columns {
            guard let dropId = row[column.0], let dropPer = row[column.1] else {
                continue
            }

            guard let dropRate = Double(dropPer) else {
                continue
            }

            let id = Expression<String>("id")
            guard let item = Database.shared.fetchItems(with: id == dropId).first else {
                continue
            }

            let droppedItem = Records.DroppedItem(item: item, dropRate: dropRate / 100)
            let record = AnyRecord(droppedItem)
            droppedItems.append(record)
        }

        return droppedItems
    }
}
