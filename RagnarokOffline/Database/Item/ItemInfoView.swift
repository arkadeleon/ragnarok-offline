//
//  ItemInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct ItemInfoView: View {
    var item: ObservableItem

    @Environment(\.horizontalSizeClass) private var sizeClass

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
                .stretchy()

                DatabaseRecordSectionView("Info", attributes: item.attributes)

                if item.type == .weapon || item.type == .armor {
                    DatabaseRecordSectionView("Jobs", text: item.jobs)

                    DatabaseRecordSectionView("Classes", text: item.classes)

                    DatabaseRecordSectionView("Locations", text: item.locations)
                }

                if let localizedDescription = item.localizedDescription {
                    DatabaseRecordSectionView("Description", text: localizedDescription)
                }

                if let script = item.script?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DatabaseRecordSectionView("Script", text: script, monospaced: true)
                }

                if let equipScript = item.equipScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DatabaseRecordSectionView("Equip Script", text: equipScript, monospaced: true)
                }

                if let unEquipScript = item.unEquipScript?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DatabaseRecordSectionView("Unequip Script", text: unEquipScript, monospaced: true)
                }

                if !item.droppingMonsters.isEmpty {
                    DatabaseRecordSectionView("Dropping Monsters") {
                        LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                            ForEach(item.droppingMonsters) { droppingMonster in
                                NavigationLink(value: droppingMonster.monster) {
                                    MonsterGridCell(monster: droppingMonster.monster, secondaryText: "(" + (Double(droppingMonster.drop.rate) / 100).formatted() + "%)")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, vSpacing(sizeClass))
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
