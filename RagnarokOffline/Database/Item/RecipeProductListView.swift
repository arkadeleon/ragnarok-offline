//
//  RecipeProductListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct RecipeProductListView: View {
    var recipeProductList: ItemModel.RecipeProductList

    @Environment(DatabaseModel.self) private var database

    @State private var recipeProducts: [ItemModel.Recipe] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(Array(recipeProducts.enumerated()), id: \.element.id) { (index, recipe) in
                DatabaseRecordSectionView {
                    RecipeView(recipe: recipe, showsProduct: true)
                } header: {
                    Text("Recipe \(index + 1)", tableName: "Database")
                }
            }
        }
        .navigationTitle(Text("Used In", tableName: "Database"))
        .task {
            recipeProducts = await database.recipeProducts(for: recipeProductList.item)
        }
    }
}
