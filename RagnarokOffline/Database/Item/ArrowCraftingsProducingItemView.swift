//
//  ArrowCraftingsProducingItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct ArrowCraftingsProducingItem: Hashable {
    var item: ItemModel
}

struct ArrowCraftingsProducingItemView: View {
    var arrowCraftingsProducingItem: ArrowCraftingsProducingItem

    @Environment(DatabaseModel.self) private var database

    @State private var arrowCraftings: [ItemModel.ArrowCrafting] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(Array(arrowCraftings.enumerated()), id: \.element.id) { (index, arrowCrafting) in
                DatabaseRecordSectionView {
                    ArrowCraftingView(arrowCrafting: arrowCrafting, showsSource: true)
                } header: {
                    Text("Crafting \(index + 1)", tableName: "Database")
                }
            }
        }
        .navigationTitle(Text("Crafted From", tableName: "Database"))
        .task {
            arrowCraftings = await database.arrowCraftings(producing: arrowCraftingsProducingItem.item)
        }
    }
}
