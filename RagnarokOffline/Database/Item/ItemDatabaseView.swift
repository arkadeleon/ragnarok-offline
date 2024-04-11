//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemDatabaseView: View {
    @ObservedObject var itemDatabase: ObservableItemDatabase

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                ForEach(itemDatabase.filteredItems) { item in
                    ItemGridCell(database: itemDatabase.database, item: item, secondaryText: nil)
                }
            }
            .padding(20)
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
        .navigationTitle("Item Database")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $itemDatabase.searchText)
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
