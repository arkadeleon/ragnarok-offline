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

    var body: some View {
        DatabaseRecordDetailView {
            if let monster = pet.monster {
                DatabaseRecordSectionView("Monster") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        NavigationLink(value: monster) {
                            MonsterGridCell(monster: monster, secondaryText: nil)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }

            DatabaseRecordSectionView("Items") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                    if let tameItem = pet.tameItem {
                        NavigationLink(value: tameItem) {
                            ItemCell(item: tameItem, secondaryText: "(Tame Item)")
                        }
                        .buttonStyle(.plain)
                    }
                    if let eggItem = pet.eggItem {
                        NavigationLink(value: eggItem) {
                            ItemCell(item: eggItem, secondaryText: "(Egg Item)")
                        }
                        .buttonStyle(.plain)
                    }
                    if let equipItem = pet.equipItem {
                        NavigationLink(value: equipItem) {
                            ItemCell(item: equipItem, secondaryText: "(Equip Item)")
                        }
                        .buttonStyle(.plain)
                    }
                    if let foodItem = pet.foodItem {
                        NavigationLink(value: foodItem) {
                            ItemCell(item: foodItem, secondaryText: "(Food Item)")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            DatabaseRecordSectionView("Info", attributes: pet.attributes)

            if let script = pet.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView("Script", text: script, monospaced: true)
            }

            if let supportScript = pet.supportScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DatabaseRecordSectionView("Support Script", text: supportScript, monospaced: true)
            }
        }
        .navigationTitle(pet.displayName)
        .task {
            await pet.fetchDetail()
        }
    }
}
