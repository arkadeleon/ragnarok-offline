//
//  RecordListViewController+Weapons.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

extension RecordListViewController {

    static func weapons() -> RecordListViewController {
        let type = Expression<String>("type")
        let items = Database.shared.fetchItems(with: type == "Weapon")
        let records = items.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.weapons
        return recordListViewController
    }
}
