//
//  ItemComboListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/24.
//

import SwiftUI

struct ItemComboListView: View {
    var itemComboList: ItemModel.ItemComboList

    @Environment(DatabaseModel.self) private var database

    @State private var itemCombos: [ItemModel.ItemCombo] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(Array(itemCombos.enumerated()), id: \.element.id) { (index, itemCombo) in
                DatabaseRecordSectionView {
                    ItemComboView(itemCombo: itemCombo)
                } header: {
                    Text("Combo \(index + 1)", tableName: "Database")
                }
            }
        }
        .navigationTitle(Text("Combos", tableName: "Database"))
        .task {
            itemCombos = await database.itemCombos(forItemAegisName: itemComboList.item.aegisName)
        }
    }
}
