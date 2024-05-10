//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import RODatabase

struct ItemDatabaseView: View {
    @ObservedObject var itemDatabase: ObservableItemDatabase

    var body: some View {
        ResponsiveView {
            List(itemDatabase.filteredItems) { item in
                NavigationLink(value: item) {
                    ItemCell(item: item, secondaryText: nil)
                }
            }
            .listStyle(.plain)
            .searchable(text: $itemDatabase.searchText, placement: .navigationBarDrawer(displayMode: .always))
        } regular: {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(itemDatabase.filteredItems) { item in
                        NavigationLink(value: item) {
                            ItemCell(item: item, secondaryText: nil)
                        }
                    }
                }
                .padding(20)
            }
            .searchable(text: $itemDatabase.searchText)
        }
        .overlay {
            if itemDatabase.loadStatus == .loading {
                ProgressView()
            }
        }
        .overlay {
            if itemDatabase.loadStatus == .loaded && itemDatabase.filteredItems.isEmpty {
                EmptyContentView("No Items")
            }
        }
        .databaseNavigationDestinations(mode: itemDatabase.mode)
        .navigationTitle("Item Database")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onSubmit(of: .search) {
            itemDatabase.filterItems()
        }
        .onChange(of: itemDatabase.searchText) { _ in
            itemDatabase.filterItems()
        }
        .task {
            await itemDatabase.fetchItems()
        }
    }
}
