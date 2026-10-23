//
//  ItemGroupSectionView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ItemGroupSectionView: View {
    var itemGroup: ItemGroupModel

    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordSectionView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(previewObtainableItems) { obtainableItem in
                    NavigationLink(value: obtainableItem.item) {
                        ItemGroupObtainableItemCell(obtainableItem: obtainableItem)
                    }
                }
            }
        } header: {
            if hasMoreObtainableItems {
                NavigationLink(value: itemGroup) {
                    HStack {
                        Text("Obtains", tableName: "Database")
                            .foregroundStyle(Color.primary)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.secondary)
                    }
                }
            } else {
                Text("Obtains", tableName: "Database")
            }
        }
        .task {
            await itemGroup.fetchDetail(database: database)
        }
    }

    private var hasMoreObtainableItems: Bool {
        (itemGroup.obtainableItems?.count ?? 0) > 9
    }

    private var previewObtainableItems: some RandomAccessCollection<ItemGroupModel.ObtainableItem> {
        (itemGroup.obtainableItems ?? []).prefix(9)
    }
}
