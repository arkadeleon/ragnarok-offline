//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @State private var searchText = ""
    @State private var filteredItems: [ItemModel] = []

    var body: some View {
        AdaptiveView {
            List(filteredItems) { item in
                NavigationLink(value: item) {
                    ItemCell(item: item)
                }
            }
            .listStyle(.plain)
        } regular: {
            List(filteredItems) { item in
                NavigationLink(value: item) {
                    HStack {
                        ItemIconImageView(item: item)
                            .frame(width: 40)
                        Text(item.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(item.type.localizedName)
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
        .background(.background)
        .navigationTitle("Item Database")
        .adaptiveSearch(text: $searchText) { searchText in
            filteredItems = await items(matching: searchText, in: database.items)
        }
        .overlay {
            if database.items.isEmpty {
                ProgressView()
            } else if !searchText.isEmpty && filteredItems.isEmpty {
                ContentUnavailableView("No Results", systemImage: "leaf.fill")
            }
        }
        .task {
            await database.fetchItems()
            filteredItems = await items(matching: searchText, in: database.items)
        }
    }

    private func items(matching searchText: String, in items: [ItemModel]) async -> [ItemModel] {
        if searchText.isEmpty {
            return items
        }

        if searchText.hasPrefix("#") {
            if let itemID = Int(searchText.dropFirst()),
               let item = items.first(where: { $0.id == itemID }) {
                return [item]
            } else {
                return []
            }
        }

        let filteredItems = items.filter { item in
            item.displayName.localizedStandardContains(searchText)
        }
        return filteredItems
    }
}

#Preview("Pre-Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .environment(DatabaseModel(mode: .renewal))
}
