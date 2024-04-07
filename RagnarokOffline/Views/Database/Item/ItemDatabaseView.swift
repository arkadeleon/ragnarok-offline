//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ItemDatabaseView: View {
    @ObservedObject var itemDatabase: ObservableItemDatabase

    var body: some View {
        AsyncContentView(status: itemDatabase.status) { items in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(itemDatabase.filteredItems) { item in
                        ItemGridCell(database: itemDatabase.database, item: item, tertiaryText: nil)
                    }
                }
                .padding(20)
            }
            .overlay {
                if itemDatabase.filteredItems.isEmpty {
                    EmptyContentView("No Items")
                }
            }
        }
        .navigationTitle("Item Database")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $itemDatabase.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
