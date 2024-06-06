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
                Table(items) {
                    TableColumn("") { item in
                        ItemIconView(item: item)
                    }
                    .width(40)
                    TableColumn("Name") { item in
                        NavigationLink(value: item) {
                            ItemNameView(item: item)
                        }
                    }
                    TableColumn("Type") { item in
                        Text(item.type.description)
                    }
                    .width(200)
                    TableColumn("Buy") { item in
                        Text(item.buy.formatted() + "z")
                    }
                    .width(150)
                    TableColumn("Sell") { item in
                        Text(item.sell.formatted() + "z")
                    }
                    .width(150)
                    TableColumn("Weight") { item in
                        Text((Double(item.weight) / 10).formatted())
                    }
                    .width(100)
                }
            }
        }
        .navigationTitle("Item Database")
    }
}

#Preview {
    ItemDatabaseView()
}
