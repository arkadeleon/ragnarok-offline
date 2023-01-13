//
//  WeaponListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct WeaponListView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        let items = Database.shared.fetchItems(with: { $0.type == "Weapon" })
        let records = items.map { AnyRecord($0) }
        let recordListViewController = RecordListViewController(records: records)
        recordListViewController.title = Strings.weapons
        return recordListViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
