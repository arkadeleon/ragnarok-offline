//
//  ItemInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemInfoView: View {
    var item: ObservableItem

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ZStack {
                    if let itemPreviewImage = item.previewImage {
                        Image(itemPreviewImage, scale: 1, label: Text(item.displayName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "leaf")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)

                DatabaseRecordAttributesSectionView("Info", attributes: item.attributes)

                if item.type == .weapon || item.type == .armor {
                    DatabaseRecordSectionView("Jobs") {
                        Text(item.jobs)
                    }

                    DatabaseRecordSectionView("Classes") {
                        Text(item.classes)
                    }

                    DatabaseRecordSectionView("Locations") {
                        Text(item.locations)
                    }
                }

                if let localizedDescription = item.localizedDescription {
                    DatabaseRecordSectionView("Description") {
                        Text(localizedDescription)
                    }
                }

                if let script = item.script {
                    DatabaseRecordSectionView("Script") {
                        Text(script.trimmingCharacters(in: .whitespacesAndNewlines))
                            .monospaced()
                    }
                }

                if let equipScript = item.equipScript {
                    DatabaseRecordSectionView("Equip Script") {
                        Text(equipScript.trimmingCharacters(in: .whitespacesAndNewlines))
                            .monospaced()
                    }
                }

                if let unEquipScript = item.unEquipScript {
                    DatabaseRecordSectionView("Unequip Script") {
                        Text(unEquipScript.trimmingCharacters(in: .whitespacesAndNewlines))
                            .monospaced()
                    }
                }

                if !item.droppingMonsters.isEmpty {
                    DatabaseRecordSectionView("Dropping Monsters", spacing: 30) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                            ForEach(item.droppingMonsters) { droppingMonster in
                                NavigationLink(value: droppingMonster.monster) {
                                    MonsterGridCell(monster: droppingMonster.monster, secondaryText: "(" + (Double(droppingMonster.drop.rate) / 100).formatted() + "%)")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(item.displayName)
        .task {
            await item.fetchDetail()
        }
    }
}
