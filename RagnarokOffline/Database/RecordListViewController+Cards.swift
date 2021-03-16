//
//  RecordListViewController+Cards.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

extension RecordListViewController {

    static func cards() -> RecordListViewController {
        let type = Expression<String>("type")
        let items = Database.shared.fetchItems(with: type == "Card")
        let records = items.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = R.string.cards
        return recordListViewController
    }
}
