//
//  PetDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetDetailView: View {
    var pet: PetModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    var body: some View {
        DatabaseRecordDetailView {
            if let monster = pet.monster {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        NavigationLink(value: monster) {
                            ImageGridCell(title: monster.displayName) {
                                MonsterImageView(monster: monster)
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Monster", tableName: "Database")
                }
            }

            DatabaseRecordSectionView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    if let tameItem = pet.tameItem {
                        NavigationLink(value: tameItem) {
                            ItemCell(item: tameItem, secondaryText: String(localized: LocalizedStringResource("(Tame Item)", table: "Database")))
                        }
                    }
                    if let eggItem = pet.eggItem {
                        NavigationLink(value: eggItem) {
                            ItemCell(item: eggItem, secondaryText: String(localized: LocalizedStringResource("(Egg Item)", table: "Database")))
                        }
                    }
                    if let equipItem = pet.equipItem {
                        NavigationLink(value: equipItem) {
                            ItemCell(item: equipItem, secondaryText: String(localized: LocalizedStringResource("(Equip Item)", table: "Database")))
                        }
                    }
                    if let foodItem = pet.foodItem {
                        NavigationLink(value: foodItem) {
                            ItemCell(item: foodItem, secondaryText: String(localized: LocalizedStringResource("(Food Item)", table: "Database")))
                        }
                    }
                }
            } header: {
                Text("Items", tableName: "Database")
            }

            DatabaseRecordSectionView(attributes: pet.attributes) {
                Text("Info", tableName: "Database")
            }

            if let script = pet.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: script, monospaced: true) {
                    Text("Script", tableName: "Database")
                }
            }

            if let supportScript = pet.supportScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView(text: supportScript, monospaced: true) {
                    Text("Support Script", tableName: "Database")
                }
            }
        }
        .navigationTitle(pet.displayName)
        .task {
            await pet.fetchDetail(database: database)
        }
    }
}
