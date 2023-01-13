//
//  MonsterListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MonsterListView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        let monsters = Database.shared.fetchMonsters()
        let records = monsters.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.monsters
        return recordListViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
