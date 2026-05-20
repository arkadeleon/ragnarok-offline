//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemDetailView: View {
    var item: ItemModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    @State private var droppingMonsters: [DroppingMonster] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let itemPreviewImage = item.previewImage {
                    Image(decorative: itemPreviewImage.cgImage, scale: 1)
                        .resizable()
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
                DatabaseRecordSectionView(text: item.jobs) {
                    Text("Jobs", tableName: "Database")
                }

                DatabaseRecordSectionView(text: item.classes) {
                    Text("Classes", tableName: "Database")
                }

                DatabaseRecordSectionView(text: item.displayLocations) {
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
                                ImageGridCell(
                                    title: droppingMonster.monster.displayName,
                                    subtitle: "(" + (Double(droppingMonster.drop.rate) / 100).formatted() + "%)"
                                ) {
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
        }
        .navigationTitle(item.displayName)
        .task {
            await item.fetchPreviewImage()
        }
        .task {
            droppingMonsters = await database.droppingMonsters(forItemAegisName: item.aegisName)
        }
    }
}
