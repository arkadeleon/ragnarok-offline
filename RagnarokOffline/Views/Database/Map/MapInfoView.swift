//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MapInfoView: View {
    let database: Database
    let map: Map

    typealias SpawnMonster = (monster: Monster, spawn: MonsterSpawn)

    @State private var mapImage: UIImage?
    @State private var spawnMonsters: [SpawnMonster] = []

    var body: some View {
        ScrollView {
            Image(uiImage: mapImage ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)

            if !spawnMonsters.isEmpty {
                DatabaseRecordInfoSection("Spawn Monsters", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                        ForEach(spawnMonsters, id: \.monster.id) { spawnMonster in
                            MonsterGridCell(database: database, monster: spawnMonster.monster) {
                                Text("\(spawnMonster.spawn.amount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
        }
        .navigationTitle(map.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMapInfo()
        }
    }

    private func loadMapInfo() async {
        mapImage = await ClientResourceBundle.shared.mapImage(forMap: map)

        do {
            var spawnMonsters: [SpawnMonster] = []
            let monsterSpawns = try await database.monsterSpawns().joined()
            for monsterSpawn in monsterSpawns {
                if monsterSpawn.mapName == map.name {
                    if let monsterID = monsterSpawn.monsterID {
                        let monster = try await database.monster(forID: monsterID)
                        if !spawnMonsters.contains(where: { $0.monster.id == monsterID }) {
                            spawnMonsters.append((monster, monsterSpawn))
                        }
                    } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                        let monster = try await database.monster(forAegisName: monsterAegisName)
                        if !spawnMonsters.contains(where: { $0.monster.aegisName == monsterAegisName }) {
                            spawnMonsters.append((monster, monsterSpawn))
                        }
                    }
                }
            }
            self.spawnMonsters = spawnMonsters
        } catch {
        }
    }
}
