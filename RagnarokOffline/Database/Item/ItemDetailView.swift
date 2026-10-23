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

    @State private var dropSources: [DropSource] = []
    @State private var shops: [ShopModel] = []
    @State private var itemGroupSources: [ItemGroupSource] = []
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

            if !dropSources.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(previewDropSources) { dropSource in
                            NavigationLink(value: dropSource.monster) {
                                DropSourceGridCell(dropSource: dropSource)
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    if hasMoreDropSources {
                        NavigationLink(value: MonstersDroppingItem(item: item)) {
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

            if !shops.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(shops) { shop in
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

            if !itemGroupSources.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(previewItemGroupSources) { itemGroupSource in
                            NavigationLink(value: itemGroupSource.item) {
                                ItemGroupSourceCell(itemGroupSource: itemGroupSource)
                            }
                        }
                    }
                } header: {
                    NavigationLink(value: ItemGroupsContainingItem(item: item)) {
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
            dropSources = await database.dropSources(forItemAegisName: item.aegisName)
        }
        .task {
            shops = await database.shops(for: item)
        }
        .task {
            itemGroupSources = await database.itemGroupSources(forItemAegisName: item.aegisName)
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

    private var previewDropSources: some RandomAccessCollection<DropSource> {
        dropSources.prefix(9)
    }

    private var previewItemGroupSources: some RandomAccessCollection<ItemGroupSource> {
        itemGroupSources.prefix(9)
    }
}
