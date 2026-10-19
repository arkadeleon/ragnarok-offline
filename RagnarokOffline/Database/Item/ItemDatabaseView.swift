//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokConstants
import RagnarokResources
import SwiftUI

struct ItemDatabaseView: View {
    @Environment(DatabaseModel.self) private var database

    @Namespace private var filterNamespace

    @State private var searchText = ""
    @State private var filter = ItemDatabaseFilter()
    @State private var filteredItems: [ItemModel] = []
    @State private var isFilterPresented = false

    var body: some View {
        SizeClassAdaptiveView {
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
        .navigationTitle(Text("Item Database", tableName: "Database"))
        .adaptiveSearch(text: $searchText)
        .toolbar {
            ToolbarItem {
                Button {
                    isFilterPresented.toggle()
                } label: {
                    Label {
                        Text("Filter", tableName: "Database")
                    } icon: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .matchedTransitionSource(id: "filter", in: filterNamespace)
            }
        }
        .overlay {
            if database.items.isEmpty {
                ProgressView()
            } else if (!searchText.isEmpty || !filter.isEmpty) && filteredItems.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("No Results", tableName: "Database")
                    } icon: {
                        Image(systemName: "leaf.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                ItemDatabaseFilterView(filter: $filter)
            }
            .adaptiveNavigationTransition(sourceID: "filter", in: filterNamespace)
        }
        .task(id: query) {
            await database.fetchItems()

            if !searchText.isEmpty {
                do {
                    try await Task.sleep(for: .milliseconds(200))
                } catch {
                    return
                }
            }

            let filteredItems = await items(matching: searchText, filter: filter)
            if !Task.isCancelled {
                self.filteredItems = filteredItems
            }
        }
    }

    private struct Query: Equatable {
        var searchText: String
        var filter: ItemDatabaseFilter
    }

    private var query: Query {
        Query(searchText: searchText, filter: filter)
    }

    private func items(matching searchText: String, filter: ItemDatabaseFilter) async -> [ItemModel] {
        let items = database.items

        if searchText.hasPrefix("#") {
            if let itemID = Int(searchText.dropFirst()),
               let item = items.first(where: { $0.id == itemID }) {
                return [item]
            } else {
                return []
            }
        }

        if searchText.isEmpty {
            return items.filter(filter.isIncluded)
        }

        let indices = await database.itemSearchIndex.indices(matching: searchText)
        return indices.map({ items[$0] }).filter(filter.isIncluded)
    }
}

#Preview("Pre-Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .prerenewal, resourceManager: .previewing))
}

#Preview("Renewal Item Database") {
    NavigationStack {
        ItemDatabaseView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(DatabaseModel(mode: .renewal, resourceManager: .previewing))
}
