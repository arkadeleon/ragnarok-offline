//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import RODatabase

struct ItemDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .item)

    var body: some View {
        DatabaseView(database: $database) { items in
            ResponsiveView {
                List(items) { item in
                    NavigationLink(value: item) {
                        ItemCell(item: item)
                    }
                }
                .listStyle(.plain)
            } regular: {
                List(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            ItemIconView(item: item)
                                .frame(width: 40)
                            ItemNameView(item: item)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(item.type.localizedStringResource)
                                .frame(width: 160, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text(item.buy.formatted() + "z")
                                .frame(width: 120, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text(item.sell.formatted() + "z")
                                .frame(width: 120, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text((Double(item.weight) / 10).formatted())
                                .frame(width: 80, alignment: .leading)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        } empty: {
            ContentUnavailableView("No Items", systemImage: "leaf.fill")
        }
        .navigationTitle("Item Database")
    }
}

#Preview {
    ItemDatabaseView()
}
