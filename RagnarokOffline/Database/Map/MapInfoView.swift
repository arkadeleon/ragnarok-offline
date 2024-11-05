//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI
import ROClientResources
import RODatabase

struct MapInfoView: View {
    var mode: DatabaseMode
    var map: Map

    typealias SpawnMonster = (monster: ObservableMonster, spawn: MonsterSpawn)

    @State private var mapImage: CGImage?
    @State private var spawnMonsters: [SpawnMonster] = []

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ZStack {
                    if let mapImage {
                        Image(mapImage, scale: 1, label: Text(map.name))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "map")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)

                if !spawnMonsters.isEmpty {
                    DatabaseRecordSectionView("Spawn Monsters", spacing: 30) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                            ForEach(spawnMonsters, id: \.monster.id) { spawnMonster in
                                NavigationLink(value: spawnMonster.monster) {
                                    MonsterGridCell(monster: spawnMonster.monster, secondaryText: "(\(spawnMonster.spawn.amount)x)")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(map.name)
        .task {
            await loadMapInfo()
        }
    }

    private func loadMapInfo() async {
        mapImage = await ClientResourceManager.default.mapImage(forMapName: map.name)

        let monsterDatabase = MonsterDatabase.database(for: mode)
        let npcDatabase = NPCDatabase.database(for: mode)

        if let monsterSpawns = try? await npcDatabase.monsterSpawns(forMap: map) {
            var spawnMonsters: [SpawnMonster] = []
            var monsters: [Monster] = []
            for monsterSpawn in monsterSpawns {
                if let monsterID = monsterSpawn.monsterID {
                    if let monster = try? await monsterDatabase.monster(forID: monsterID) {
                        if !monsters.contains(monster) {
                            monsters.append(monster)
                            let monster = ObservableMonster(mode: mode, monster: monster)
                            spawnMonsters.append((monster, monsterSpawn))
                        }
                    }
                } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                    if let monster = try? await monsterDatabase.monster(forAegisName: monsterAegisName) {
                        if !monsters.contains(monster) {
                            monsters.append(monster)
                            let monster = ObservableMonster(mode: mode, monster: monster)
                            spawnMonsters.append((monster, monsterSpawn))
                        }
                    }
                }
            }
            self.spawnMonsters = spawnMonsters
        }
    }
}
