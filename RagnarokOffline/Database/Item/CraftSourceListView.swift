//
//  CraftSourceListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct CraftSourceListView: View {
    var craftSourceList: ItemModel.CraftSourceList

    @Environment(DatabaseModel.self) private var database

    @State private var craftSources: [ItemModel.ArrowCrafting] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(Array(craftSources.enumerated()), id: \.element.id) { (index, arrowCrafting) in
                DatabaseRecordSectionView {
                    ArrowCraftingView(arrowCrafting: arrowCrafting, showsSource: true)
                } header: {
                    Text("Crafting \(index + 1)", tableName: "Database")
                }
            }
        }
        .navigationTitle(Text("Crafted From", tableName: "Database"))
        .task {
            craftSources = await database.craftSources(for: craftSourceList.item)
        }
    }
}
