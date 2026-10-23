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

    @State private var droppingMonsters: [DroppingMonster] = []
    @State private var sellingShops: [ShopModel] = []
    @State private var petUsages: [PetUsage] = []
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

            if !droppingMonsters.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(droppingMonsters) { droppingMonster in
                            NavigationLink(value: droppingMonster.monster) {
                                ImageGridCell(title: droppingMonster.monster.displayName) {
                                    HStack(spacing: 4) {
                                        RateBadge(rate: droppingMonster.drop.rate)
                                        if droppingMonster.isMVPDrop {
                                            MVPBadge()
                                        }
                                    }
                                } image: {
                                    MonsterImageView(monster: droppingMonster.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Dropped By", tableName: "Database")
                }
            }

            if !sellingShops.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(sellingShops) { shop in
                            NavigationLink(value: shop) {
                                NPCGridCell(npc: shop.npc) {
                                    MapBadge(map: shop.map)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Sold By", tableName: "Database")
                }
            }

            if !petUsages.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(petUsages) { petUsage in
                            if let monster = petUsage.pet.monster {
                                NavigationLink(value: petUsage.pet) {
                                    ImageGridCell(title: monster.displayName) {
                                        PetUsageBadge(kind: petUsage.kind)
                                    } image: {
                                        MonsterImageView(monster: monster)
                                    }
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
            droppingMonsters = await database.droppingMonsters(forItemAegisName: item.aegisName)
        }
        .task {
            sellingShops = await database.sellingShops(for: item)
        }
        .task {
            petUsages = await database.petUsages(forItemNamed: item.aegisName)
        }
        .task {
            itemGroups = await database.itemGroups(for: item)
        }
        .task {
            monsterSummon = await database.monsterSummon(for: item)
        }
    }
}
