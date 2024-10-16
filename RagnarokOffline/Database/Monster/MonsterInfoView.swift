//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterInfoView: View {
    var monster: ObservableMonster

    @State private var monsterImage: CGImage?

    var body: some View {
        ScrollView {
            ZStack {
                if let monsterImage {
                    if monsterImage.height > 200 {
                        Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                    }
                } else {
                    Image(systemName: "pawprint")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
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
                            .buttonStyle(.plain)
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
                            .buttonStyle(.plain)
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
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .background(.background)
        .navigationTitle(monster.localizedName)
        .task {
            monsterImage = await monster.fetchImage()
            try? await monster.fetchDetail()
        }
    }
}
