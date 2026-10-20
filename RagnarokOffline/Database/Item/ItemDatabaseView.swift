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
                        Text(formatZeny(item.buy))
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(formatZeny(item.sell))
                            .frame(width: 120, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text(formatWeight(item.weight))
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
                // The button looks selected while the filter is active, and a click opens the filter.
                let isFilterOn = Binding(get: { !filter.isEmpty }, set: { _ in isFilterPresented.toggle() })
                Toggle(isOn: isFilterOn) {
                    Label {
                        Text("Filter", tableName: "Database")
                    } icon: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .toggleStyle(.button)
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
                } description: {
                    Text("Try adjusting your search or filters", tableName: "Database")
                } actions: {
                    if !filter.isEmpty {
                        Button {
                            filter.reset()
                        } label: {
                            Label {
                                Text("Reset Filters", tableName: "Database")
                            } icon: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        }
                        .adaptiveProminentButtonStyle()
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
