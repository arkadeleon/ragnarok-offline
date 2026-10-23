//
//  MapDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import RagnarokDatabase
import SwiftUI

struct MapDetailView: View {
    var map: MapModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    @State private var mapFlags: [MapFlag] = []
    @State private var spawnMonsters: [SpawnMonster] = []
    @State private var warpMaps: [MapModel] = []
    @State private var npcs: [NPCModel] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let mapImage = map.originalImage {
                    Image(decorative: mapImage.cgImage, scale: 1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "map")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            if !mapFlags.isEmpty {
                DatabaseRecordSectionView {
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                        ForEach(mapFlags.indices, id: \.self) { index in
                            GridRow {
                                Text(mapFlags[index].flag)
                                Text(mapFlags[index].value ?? "")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
                } header: {
                    Text("Map Flags", tableName: "Database")
                }
            }

            if !spawnMonsters.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(spawnMonsters) { spawnMonster in
                            NavigationLink(value: spawnMonster.monster) {
                                ImageGridCell(title: spawnMonster.monster.displayName) {
                                    SpawnBadge(spawn: spawnMonster.spawn)
                                } image: {
                                    MonsterImageView(monster: spawnMonster.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("Monsters", tableName: "Database")
                }
            }

            if !warpMaps.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(warpMaps) { warpMap in
                            NavigationLink(value: warpMap) {
                                MapCell(map: warpMap)
                            }
                        }
                    }
                } header: {
                    Text("Warps", tableName: "Database")
                }
            }

            if !npcs.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(npcs) { npc in
                            NPCGridCell(npc: npc) {
                                PositionBadge(x: npc.x, y: npc.y)
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                } header: {
                    Text("NPCs", tableName: "Database")
                }
            }
        }
        .navigationTitle(map.displayName)
        .task {
            await map.fetchOriginalImage()
        }
        .task {
            mapFlags = await database.mapFlags(forMapName: map.name)
        }
        .task {
            spawnMonsters = await database.spawnMonsters(forMapName: map.name)
        }
        .task {
            warpMaps = await database.warpMaps(forMapName: map.name)
        }
        .task {
            npcs = await database.npcs(forMapName: map.name)
        }
    }
}
