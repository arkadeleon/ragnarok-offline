//
//  MonsterDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterDetailView: View {
    var monster: MonsterModel

    @Environment(DatabaseModel.self) private var database

    @State private var mvpDropItems: [DropItem] = []
    @State private var dropItems: [DropItem] = []
    @State private var spawnMaps: [SpawnMap] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let animatedImage = monster.animatedImage {
                    AnimatedImageView(animatedImage: animatedImage)
                } else {
                    Image(systemName: "pawprint")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            DatabaseRecordSectionView("Info", attributes: monster.attributes)

            if let raceGroups = monster.raceGroups {
                DatabaseRecordSectionView("Race Groups", text: raceGroups)
            }

            if let modes = monster.modes {
                DatabaseRecordSectionView("Modes", text: modes)
            }

            if !mvpDropItems.isEmpty {
                DatabaseRecordSectionView("MVP Drops") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(mvpDropItems) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(" + (Double(dropItem.drop.rate) / 100).formatted() + "%)")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !dropItems.isEmpty {
                DatabaseRecordSectionView("Drops") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(dropItems) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(" + (Double(dropItem.drop.rate) / 100).formatted() + "%)")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !spawnMaps.isEmpty {
                DatabaseRecordSectionView("Maps") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(spawnMaps) { spawnMap in
                            NavigationLink(value: spawnMap.map) {
                                MapCell(map: spawnMap.map, secondaryText: "(\(spawnMap.monsterSpawn.amount)x)")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle(monster.displayName)
        .task {
            await monster.fetchAnimatedImage()
        }
        .task {
            if let mvpDrops = monster.mvpDrops {
                mvpDropItems = await database.dropItems(for: mvpDrops)
            }
        }
        .task {
            if let drops = monster.drops {
                dropItems = await database.dropItems(for: drops)
            }
        }
        .task {
            let monster = (monster.id, monster.aegisName)
            spawnMaps = await database.spawnMaps(for: monster)
        }
    }
}
