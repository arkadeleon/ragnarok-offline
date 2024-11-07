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
            LazyVStack(pinnedViews: .sectionHeaders) {
                DatabaseRecordSectionView("Monster") {
                    if let monster = pet.monster {
                        NavigationLink(value: monster) {
                            MonsterGridCell(monster: monster, secondaryText: nil)
                        }
                        .buttonStyle(.plain)
                    }
                }

                DatabaseRecordSectionView("Items", spacing: 20) {
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

                DatabaseRecordAttributesSectionView("Info", attributes: pet.attributes)

                if let script = pet.script {
                    DatabaseRecordSectionView("Script") {
                        Text(script)
                            .monospaced()
                    }
                }

                if let supportScript = pet.supportScript {
                    DatabaseRecordSectionView("Support Script") {
                        Text(supportScript)
                            .monospaced()
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(pet.displayName)
        .task {
            await pet.fetchDetail()
        }
    }
}
