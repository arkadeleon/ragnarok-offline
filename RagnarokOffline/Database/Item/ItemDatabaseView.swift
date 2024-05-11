//
//  ItemDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import RODatabase

struct ItemDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<ItemProvider>

    var body: some View {
        DatabaseView(database: database) { items in
            ResponsiveView {
                List(items) { item in
                    NavigationLink(value: item) {
                        ItemCell(item: item, secondaryText: nil)
                    }
                }
                .listStyle(.plain)
            } regular: {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                ItemCell(item: item, secondaryText: nil)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Item Database")
    }
}

#Preview {
    ItemDatabaseView(database: .init(mode: .renewal, recordProvider: .item))
}
