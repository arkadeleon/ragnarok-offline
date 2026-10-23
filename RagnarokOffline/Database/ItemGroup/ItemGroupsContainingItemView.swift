//
//  ItemGroupsContainingItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ItemGroupsContainingItem: Hashable {
    var item: ItemModel
}

struct ItemGroupsContainingItemView: View {
    var itemGroupsContainingItem: ItemGroupsContainingItem

    @Environment(DatabaseModel.self) private var database

    @State private var itemGroupSources: [ItemGroupSource] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(itemGroups, id: \.displayName) { itemGroup in
                DatabaseRecordSectionView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(itemGroup.subGroupListItemChances(forItemAegisName: itemAegisName)) { subGroupListItemChance in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("SubGroup \(subGroupListItemChance.subGroup.subGroup) (\(String(localized: subGroupListItemChance.subGroup.algorithm.localizedName)))", tableName: "Database")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                                    ForEach(sourceItems(of: itemGroup)) { item in
                                        NavigationLink(value: item) {
                                            let itemGroupSource = ItemGroupSource(item: item, itemGroup: itemGroup, subGroupListItemChance: subGroupListItemChance)
                                            ItemGroupSourceCell(itemGroupSource: itemGroupSource)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    NavigationLink(value: itemGroup) {
                        HStack {
                            Text(itemGroup.displayName)
                                .foregroundStyle(Color.primary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("Obtained From", tableName: "Database"))
        .task {
            itemGroupSources = await database.itemGroupSources(forItemAegisName: itemAegisName)
        }
    }

    private var itemAegisName: String {
        itemGroupsContainingItem.item.aegisName
    }

    private func sourceItems(of itemGroup: ItemGroupModel) -> [ItemModel] {
        itemGroupSources.filter({ $0.itemGroup == itemGroup }).map(\.item)
    }

    /// The item groups of `itemGroupSources`, in the order they first appear.
    private var itemGroups: [ItemGroupModel] {
        var itemGroups: [ItemGroupModel] = []
        for itemGroupSource in itemGroupSources where !itemGroups.contains(itemGroupSource.itemGroup) {
            itemGroups.append(itemGroupSource.itemGroup)
        }
        return itemGroups
    }
}
