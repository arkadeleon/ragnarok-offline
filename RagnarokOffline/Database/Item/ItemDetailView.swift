//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import RagnarokCore
import SwiftUI

struct ItemDetailView: View {
    var item: ItemModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    @State private var itemCombos: [ItemModel.ItemCombo] = []
    @State private var recipeSources: [ItemModel.Recipe] = []
    @State private var recipeProducts: [ItemModel.Recipe] = []
    @State private var craftSources: [ItemModel.ArrowCrafting] = []
    @State private var craftProduct: ItemModel.ArrowCrafting?
    @State private var dropSources: [ItemModel.DropSource] = []
    @State private var shopNPCs: [NPCModel] = []
    @State private var obtainSources: [ItemModel.ObtainSource] = []
    @State private var petUsages: [ItemModel.PetUsage] = []
    @State private var itemGroups: [ItemGroupModel] = []
    @State private var monsterSummon: MonsterSummonModel?

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let itemPreviewImage = item.previewImage {
                    Image(decorative: itemPreviewImage.cgImage, scale: 1)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "leaf")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            DatabaseRecordSectionView(attributes: item.attributes) {
                Text("Info", tableName: "Database")
            }

            if item.type == .weapon || item.type == .armor {
                DatabaseRecordSectionView(tags: item.localizedJobs) {
                    Text("Jobs", tableName: "Database")
                }

                DatabaseRecordSectionView(tags: item.localizedClasses) {
                    Text("Classes", tableName: "Database")
                }

                DatabaseRecordSectionView(tags: item.localizedLocations) {
                    Text("Locations", tableName: "Database")
                }
            }

            if let localizedDescription = item.localizedDescription {
                DatabaseRecordSectionView(text: AttributedString(description: localizedDescription)) {
                    Text("Description", tableName: "Database")
                }
            }

            if let script = item.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: script, monospaced: true) {
                    Text("Script", tableName: "Database")
                }
            }

            if let equipScript = item.equipScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: equipScript, monospaced: true) {
                    Text("Equip Script", tableName: "Database")
                }
            }

            if let unEquipScript = item.unEquipScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: unEquipScript, monospaced: true) {
                    Text("Unequip Script", tableName: "Database")
                }
            }

            if let itemCombo = itemCombos.first {
                DatabaseRecordSectionView {
                    ItemComboView(itemCombo: itemCombo)
                } header: {
                    if itemCombos.count > 1 {
                        NavigationLink(value: ItemModel.ItemComboList(item: item)) {
                            HStack {
                                Text("Combos", tableName: "Database")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    } else {
                        Text("Combos", tableName: "Database")
                    }
                }
            }

            ForEach(Array(recipeSources.enumerated()), id: \.element.id) { (index, recipe) in
                DatabaseRecordSectionView {
                    RecipeView(recipe: recipe, showsProduct: false)
                } header: {
                    if recipeSources.count > 1 {
                        Text("Recipe \(index + 1)", tableName: "Database")
                    } else {
                        Text("Recipe", tableName: "Database")
                    }
                }
            }

            if let craftSource = craftSources.first {
                DatabaseRecordSectionView {
                    ArrowCraftingView(arrowCrafting: craftSource, showsSource: true)
                } header: {
                    if craftSources.count > 1 {
                        NavigationLink(value: ItemModel.CraftSourceList(item: item)) {
                            HStack {
                                Text("Arrow Crafting", tableName: "Database")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    } else {
                        Text("Arrow Crafting", tableName: "Database")
                    }
                }
            }

            if let recipeProduct = recipeProducts.first {
                DatabaseRecordSectionView {
                    RecipeView(recipe: recipeProduct, showsProduct: true)
                } header: {
                    if recipeProducts.count > 1 {
                        NavigationLink(value: ItemModel.RecipeProductList(item: item)) {
                            HStack {
                                Text("Material For", tableName: "Database")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    } else {
                        Text("Material For", tableName: "Database")
                    }
                }
            }

            if let craftProduct {
                DatabaseRecordSectionView {
                    ArrowCraftingView(arrowCrafting: craftProduct, showsSource: false)
                } header: {
                    Text("Arrow Crafting", tableName: "Database")
                }
            }

            if !dropSources.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(previewDropSources) { dropSource in
                            NavigationLink(value: dropSource.monster) {
                                ImageGridCell(title: dropSource.monster.displayName, badges: dropSource.badges) {
                                    MonsterImageView(monster: dropSource.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    if hasMoreDropSources {
                        NavigationLink(value: ItemModel.DropSourceList(item: item)) {
                            HStack {
                                Text("Dropped By", tableName: "Database")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    } else {
                        Text("Dropped By", tableName: "Database")
                    }
                }
            }

            if !shopNPCs.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(shopNPCs) { shopNPC in
                            NavigationLink(value: shopNPC) {
                                NPCGridCell(npc: shopNPC, badges: [.map(shopNPC.map)])
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Sold By", tableName: "Database")
                }
            }

            if !obtainSources.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(previewObtainSources) { obtainSource in
                            NavigationLink(value: obtainSource.item) {
                                ItemCell(item: obtainSource.item, badges: obtainSource.badges)
                            }
                        }
                    }
                } header: {
                    NavigationLink(value: ItemModel.ObtainSourceList(item: item)) {
                        HStack {
                            Text("Obtained From", tableName: "Database")
                                .foregroundStyle(Color.primary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }

            if !petUsages.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(petUsages) { petUsage in
                            NavigationLink(value: petUsage.monster) {
                                ImageGridCell(title: petUsage.monster.displayName, badges: petUsage.badges) {
                                    MonsterImageView(monster: petUsage.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Pets", tableName: "Database")
                }
            }

            ForEach(itemGroups, id: \.displayName) { itemGroup in
                ItemGroupSectionView(itemGroup: itemGroup)
            }

            if let monsterSummon {
                MonsterSummonSectionView(monsterSummon: monsterSummon)
            }
        }
        .navigationTitle(item.displayName)
        .task {
            await item.fetchPreviewImage()
        }
        .task {
            itemCombos = await database.itemCombos(forItemAegisName: item.aegisName)
        }
        .task {
            recipeSources = await database.recipeSources(for: item)
        }
        .task {
            recipeProducts = await database.recipeProducts(for: item)
        }
        .task {
            craftSources = await database.craftSources(for: item)
        }
        .task {
            craftProduct = await database.craftProduct(for: item)
        }
        .task {
            dropSources = await database.dropSources(forItemAegisName: item.aegisName)
        }
        .task {
            shopNPCs = await database.shopNPCs(for: item)
        }
        .task {
            obtainSources = await database.obtainSources(forItemAegisName: item.aegisName)
        }
        .task {
            petUsages = await database.petUsages(forItemAegisName: item.aegisName)
        }
        .task {
            itemGroups = await database.itemGroups(for: item)
        }
        .task {
            monsterSummon = await database.monsterSummon(for: item)
        }
    }

    private var hasMoreDropSources: Bool {
        dropSources.count > 9
    }

    private var previewDropSources: some RandomAccessCollection<ItemModel.DropSource> {
        dropSources.prefix(9)
    }

    private var previewObtainSources: some RandomAccessCollection<ItemModel.ObtainSource> {
        obtainSources.prefix(9)
    }
}
