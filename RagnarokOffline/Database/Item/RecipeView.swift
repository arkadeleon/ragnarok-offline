//
//  RecipeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct RecipeView: View {
    var recipe: ItemModel.Recipe
    var showsProduct: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if showsProduct {
                DatabaseRecordSubsectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        NavigationLink(value: recipe.product) {
                            ItemCell(item: recipe.product)
                        }
                    }
                } header: {
                    Text("Product", tableName: "Database")
                }
            }

            if let skill = recipe.skill {
                DatabaseRecordSubsectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        NavigationLink(value: skill) {
                            SkillCell(skill: skill, badges: [.skillLevel(recipe.skillLevel)])
                        }
                    }
                } header: {
                    Text("Skill", tableName: "Database")
                }
            }

            DatabaseRecordSubsectionView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    ForEach(recipe.materials) { material in
                        NavigationLink(value: material.item) {
                            ItemCell(item: material.item, badges: material.badges)
                        }
                    }
                }
            } header: {
                Text("Materials", tableName: "Database")
            }
        }
    }
}
