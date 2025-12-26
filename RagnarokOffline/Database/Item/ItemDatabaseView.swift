//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokLocalization
import SwiftUI

struct ItemDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @Namespace private var filterNamespace

    @State private var filter = ItemDatabaseFilter()
    @State private var filteredItems: [ItemModel] = []
    @State private var isFilterPresented = false

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
        .adaptiveSearch(text: $filter.searchText)
        .toolbar {
            ToolbarItem {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {
                    isFilterPresented.toggle()
                }
                .matchedTransitionSource(id: "filter", in: filterNamespace)
            }
        }
        .overlay {
            if database.items.isEmpty {
                ProgressView()
            } else if !filter.isEmpty && filteredItems.isEmpty {
                ContentUnavailableView("No Results", systemImage: "leaf.fill")
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                ItemDatabaseFilterView(filter: filter)
            }
            #if os(macOS)
            .navigationTransition(.automatic)
            #else
            .navigationTransition(.zoom(sourceID: "filter", in: filterNamespace))
            #endif
        }
        .task(id: filter.identifier) {
            await database.fetchItems()
            filteredItems = await items(matching: filter, in: database.items)
        }
    }

    private func items(matching filter: ItemDatabaseFilter, in items: [ItemModel]) async -> [ItemModel] {
        if filter.searchText.hasPrefix("#") {
            if let itemID = Int(filter.searchText.dropFirst()),
               let item = items.first(where: { $0.id == itemID }) {
                return [item]
            } else {
                return []
            }
        }

        let filteredItems = items.filter(filter.isIncluded)
        return filteredItems
    }
}

#Preview("Pre-Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal))
}

#Preview("Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal))
}
