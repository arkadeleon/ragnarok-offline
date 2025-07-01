//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemDatabaseView: View {
    @Environment(ObservableDatabase<ItemProvider>.self) private var database

    var body: some View {
        AdaptiveView {
            List(database.filteredRecords) { item in
                NavigationLink(value: item) {
                    ItemCell(item: item)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { item in
                NavigationLink(value: item) {
                    HStack {
                        ItemIconImageView(item: item)
                            .frame(width: 40)
                        Text(item.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(item.type.localizedStringResource)
                            .frame(width: 160, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(item.buy.formatted() + "z")
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(item.sell.formatted() + "z")
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text((Double(item.weight) / 10).formatted())
                            .frame(width: 80, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Item Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "leaf.fill")
        }
    }
}

#Preview("Pre-Renewal Item Database") {
    ItemDatabaseView()
        .environment(ObservableDatabase(mode: .prerenewal, recordProvider: .item))
}

#Preview("Renewal Item Database") {
    ItemDatabaseView()
        .environment(ObservableDatabase(mode: .renewal, recordProvider: .item))
}
