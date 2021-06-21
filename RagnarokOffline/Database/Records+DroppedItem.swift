//
//  Records+DroppedItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/17.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

extension Records {

    struct DroppedItem: Record {

        let item: Item
        let dropRate: Double

        init(item: Item, dropRate: Double) {
            self.item = item
            self.dropRate = dropRate
        }

        var id: String {
            return "\(item.id)(\(dropRate)"
        }

        var name: String {
            return "\(item.name) (\(dropRate)%)"
        }

        var fields: [RecordField] {
            return item.fields
        }
    }
}
