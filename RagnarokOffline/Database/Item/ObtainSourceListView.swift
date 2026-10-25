//
//  ObtainSourceListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ObtainSourceListView: View {
    var obtainSourceList: ItemModel.ObtainSourceList

    @Environment(DatabaseModel.self) private var database

    @State private var obtainSources: [ItemModel.ObtainSource] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(itemGroups, id: \.displayName) { itemGroup in
                DatabaseRecordSectionView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(itemGroup.subGroupListItemChances(forItemAegisName: itemAegisName)) { subGroupListItemChance in
                            DatabaseRecordSubsectionView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                                    ForEach(sourceItems(of: itemGroup)) { item in
                                        NavigationLink(value: item) {
                                            let obtainSource = ItemModel.ObtainSource(item: item, itemGroup: itemGroup, subGroupListItemChance: subGroupListItemChance)
                                            ItemCell(item: obtainSource.item, badges: obtainSource.badges)
                                        }
                                    }
                                }
                            } header: {
                                Text("SubGroup \(subGroupListItemChance.subGroup.subGroup) (\(String(localized: subGroupListItemChance.subGroup.algorithm.localizedName)))", tableName: "Database")
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
            obtainSources = await database.obtainSources(forItemAegisName: itemAegisName)
        }
    }

    private var itemAegisName: String {
        obtainSourceList.item.aegisName
    }

    private func sourceItems(of itemGroup: ItemGroupModel) -> [ItemModel] {
        obtainSources.filter({ $0.itemGroup == itemGroup }).map(\.item)
    }

    /// The item groups of `obtainSources`, in the order they first appear.
    private var itemGroups: [ItemGroupModel] {
        var itemGroups: [ItemGroupModel] = []
        for obtainSource in obtainSources where !itemGroups.contains(obtainSource.itemGroup) {
            itemGroups.append(obtainSource.itemGroup)
        }
        return itemGroups
    }
}
