//
//  PetInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/8.
//

import SwiftUI

struct PetInfoView: View {
    var pet: ObservablePet

    var body: some View {
        ScrollView {
            DatabaseRecordInfoSection("Monster", verticalSpacing: 0) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                    NavigationLink(value: pet.monster) {
                        MonsterGridCell(monster: pet.monster, secondaryText: nil)
                    }
                }
                .padding(.vertical, 30)
            }

            DatabaseRecordInfoSection("Items", verticalSpacing: 0) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    if let tameItem = pet.tameItem {
                        NavigationLink(value: tameItem) {
                            ItemCell(item: tameItem, secondaryText: "(Tame Item)")
                        }
                    }
                    if let eggItem = pet.eggItem {
                        NavigationLink(value: eggItem) {
                            ItemCell(item: eggItem, secondaryText: "(Egg Item)")
                        }
                    }
                    if let equipItem = pet.equipItem {
                        NavigationLink(value: equipItem) {
                            ItemCell(item: equipItem, secondaryText: "(Equip Item)")
                        }
                    }
                    if let foodItem = pet.foodItem {
                        NavigationLink(value: foodItem) {
                            ItemCell(item: foodItem, secondaryText: "(Food Item)")
                        }
                    }
                }
                .padding(.vertical, 20)
            }

            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(pet.fields, id: \.title) { field in
                        LabeledContent(field.title, value: field.value)
                    }
                }
            }

            if let script = pet.pet.script {
                DatabaseRecordInfoSection("Script") {
                    Text(script)
                        .monospaced()
                }
            }

            if let supportScript = pet.pet.supportScript {
                DatabaseRecordInfoSection("Support Script") {
                    Text(supportScript)
                        .monospaced()
                }
            }
        }
        .navigationTitle(pet.monster.name)
        .task {
            await pet.fetchPetInfo()
        }
    }
}
