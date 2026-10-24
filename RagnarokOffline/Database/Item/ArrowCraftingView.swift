//
//  ArrowCraftingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct ArrowCraftingView: View {
    var arrowCrafting: ItemModel.ArrowCrafting
    var showsSource: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if showsSource {
                DatabaseRecordSubsectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        NavigationLink(value: arrowCrafting.source) {
                            ItemCell(item: arrowCrafting.source, badges: [.amount(1)])
                        }
                    }
                } header: {
                    Text("Source", tableName: "Database")
                }
            }

            DatabaseRecordSubsectionView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(arrowCrafting.products) { product in
                        NavigationLink(value: product.item) {
                            ItemCell(item: product.item, badges: product.badges)
                        }
                    }
                }
            } header: {
                Text("Products", tableName: "Database")
            }
        }
    }
}
