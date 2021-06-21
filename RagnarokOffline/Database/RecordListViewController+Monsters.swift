//
//  RecordListViewController+Monsters.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

extension RecordListViewController {

    static func monsters() -> RecordListViewController {
        let monsters = Database.shared.fetchMonsters()
        let records = monsters.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.monsters
        return recordListViewController
    }
}
