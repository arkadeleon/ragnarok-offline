//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterInfoView: View {
    var monster: ObservableMonster

    var body: some View {
        ScrollView {
            ZStack {
                if let monsterImage = monster.image {
                    if monsterImage.height > 200 {
                        Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                    }
                } else {
                    Image(systemName: "pawprint")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 100))
                }
            }
            .frame(height: 200)

            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(monster.attributes) { attribute in
                        LabeledContent {
                            Text(attribute.value)
                        } label: {
                            Text(attribute.name)
                        }
                    }
                }
            }

            if let raceGroups = monster.raceGroups {
                DatabaseRecordInfoSection("Race Groups") {
                    Text(raceGroups)
                }
            }

            if let modes = monster.modes {
                DatabaseRecordInfoSection("Modes") {
                    Text(modes)
                }
            }

            if !monster.mvpDropItems.isEmpty {
                DatabaseRecordInfoSection("MVP Drops", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(monster.mvpDropItems, id: \.index) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(" + (Double(dropItem.drop.rate) / 100).formatted() + "%)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            if !monster.dropItems.isEmpty {
                DatabaseRecordInfoSection("Drops", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(monster.dropItems, id: \.index) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(" + (Double(dropItem.drop.rate) / 100).formatted() + "%)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            if !monster.spawnMaps.isEmpty {
                DatabaseRecordInfoSection("Maps", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(monster.spawnMaps, id: \.map.index) { spawnMap in
                            NavigationLink(value: spawnMap.map) {
                                MapCell(map: spawnMap.map, secondaryText: "(\(spawnMap.monsterSpawn.amount)x)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle(monster.localizedName)
        .task {
            await monster.fetchImage()
            try? await monster.fetchDetail()
        }
    }
}
