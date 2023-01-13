//
//  ItemListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ItemListView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        let items = Database.shared.fetchItems(with: { $0.type != "Weapon" && $0.type != "Armor" && $0.type != "Card" })
        let records = items.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.items
        return recordListViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
