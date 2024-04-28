//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI
import RODatabase

struct MapInfoView: View {
    let database: Database
    let map: Map

    typealias SpawnMonster = (monster: Monster, spawn: MonsterSpawn)

    @State private var mapImage: CGImage?
    @State private var spawnMonsters: [SpawnMonster] = []

    var body: some View {
        ScrollView {
            ZStack {
                if let mapImage {
                    Image(mapImage, scale: 1, label: Text(map.name))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "map")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 100))
                }
            }
            .frame(height: 200)

            if !spawnMonsters.isEmpty {
                DatabaseRecordInfoSection("Spawn Monsters", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                        ForEach(spawnMonsters, id: \.monster.id) { spawnMonster in
                            NavigationLink(value: spawnMonster.monster) {
                                MonsterGridCell(monster: spawnMonster.monster, secondaryText: "(\(spawnMonster.spawn.amount)x)")
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
            let monsterSpawns = try await database.monsterSpawns(forMap: map)
            for monsterSpawn in monsterSpawns {
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
            self.spawnMonsters = spawnMonsters
        } catch {
        }
    }
}
