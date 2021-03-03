//
//  NSDiffableDataSourceSnapshot+Record.swift
//  RagnarokOffline
//
//  Created by Li, Junlin on 2021/3/2.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import UIKit
import SQLite

extension NSDiffableDataSourceSnapshot where SectionIdentifierType == Int, ItemIdentifierType == Record {

    static func snapshotForWeapons() -> Self {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Record>()
        var records: [Record] = []

        let items = Table("item_db")
        let type = Expression<String>("type")
        let query = items.filter(type == "Weapon")
        if let rows = try? Database.client.perform(query) {
            for row in rows {
                let record: Record = .item(row: row)
                records.append(record)
            }
        }

        snapshot.appendSections([0])
        snapshot.appendItems(records, toSection: 0)

        return snapshot
    }
}
