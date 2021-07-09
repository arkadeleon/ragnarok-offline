//
//  RecordListViewController+Items.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

extension RecordListViewController {

    static func items() -> RecordListViewController {
        let items = Database.shared.fetchItems(with: { $0.type != "Weapon" && $0.type != "Armor" && $0.type != "Card" })
        let records = items.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.items
        return recordListViewController
    }
}
