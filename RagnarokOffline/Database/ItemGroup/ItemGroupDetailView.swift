//
//  ItemGroupDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ItemGroupDetailView: View {
    var itemGroup: ItemGroupModel

    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(itemGroup.subGroups.sorted(by: { $0.subGroup < $1.subGroup }), id: \.subGroup) { subGroup in
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach((itemGroup.obtainableItems ?? []).filter({ $0.subGroupNumber == subGroup.subGroup })) { obtainableItem in
                            NavigationLink(value: obtainableItem.item) {
                                ItemGroupObtainableItemCell(obtainableItem: obtainableItem)
                            }
                        }
                    }
                } header: {
                    Text("SubGroup \(subGroup.subGroup) (\(String(localized: subGroup.algorithm.localizedName)))", tableName: "Database")
                }
            }
        }
        .navigationTitle(itemGroup.displayName)
        .task {
            await itemGroup.fetchDetail(database: database)
        }
    }
}
