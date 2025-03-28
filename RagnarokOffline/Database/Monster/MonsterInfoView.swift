//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import ROCore
import SwiftUI

struct MonsterInfoView: View {
    var monster: ObservableMonster

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
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

                DatabaseRecordSectionView("Info", attributes: monster.attributes)

                if let raceGroups = monster.raceGroups {
                    DatabaseRecordSectionView("Race Groups", text: raceGroups)
                }

                if let modes = monster.modes {
                    DatabaseRecordSectionView("Modes", text: modes)
                }

                if !monster.mvpDropItems.isEmpty {
                    DatabaseRecordSectionView("MVP Drops") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(monster.mvpDropItems) { dropItem in
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
                    DatabaseRecordSectionView("Drops") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(monster.dropItems) { dropItem in
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
                    DatabaseRecordSectionView("Maps") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                            ForEach(monster.spawnMaps) { spawnMap in
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
        }
        .background(.background)
        .navigationTitle(monster.displayName)
        .task {
            await monster.fetchAnimatedImage()
            await monster.fetchDetail()
        }
    }
}
