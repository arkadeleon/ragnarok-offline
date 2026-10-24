//
//  RecipesConsumingItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct RecipesConsumingItem: Hashable {
    var item: ItemModel
}

struct RecipesConsumingItemView: View {
    var recipesConsumingItem: RecipesConsumingItem

    @Environment(DatabaseModel.self) private var database

    @State private var recipes: [ItemModel.Recipe] = []

    var body: some View {
        DatabaseRecordDetailView {
            ForEach(Array(recipes.enumerated()), id: \.element.id) { (index, recipe) in
                DatabaseRecordSectionView {
                    RecipeView(recipe: recipe, showsProduct: true)
                } header: {
                    Text("Recipe \(index + 1)", tableName: "Database")
                }
            }
        }
        .navigationTitle(Text("Used In", tableName: "Database"))
        .task {
            recipes = await database.recipes(consuming: recipesConsumingItem.item)
        }
    }
}
