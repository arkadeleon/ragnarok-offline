//
//  ObservableMap.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
import ROClientResources
import RODatabase
import ROResources

@Observable
@dynamicMemberLookup
class ObservableMap {
    struct SpawnMonster: Identifiable {
        var monster: ObservableMonster
        var spawn: MonsterSpawn

        var id: Int {
            monster.id
        }
    }

    private let mode: DatabaseMode
    private let map: Map

    var localizedName: String?
    var image: CGImage?
    var spawnMonsters: [SpawnMonster] = []

    var displayName: String {
        localizedName ?? map.name
    }

    init(mode: DatabaseMode, map: Map) {
        self.mode = mode
        self.map = map
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Map, Value>) -> Value {
        map[keyPath: keyPath]
    }

    func fetchLocalizedName() {
        localizedName = MapInfoTable.shared.localizedMapName(forMapName: map.name)
    }

    func fetchImage() async {
        if image == nil {
            image = await ClientResourceManager.default.mapImage(forMapName: map.name)
        }
    }

    func fetchDetail() async {
        await fetchImage()

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

                            let spawnMonster = SpawnMonster(
                                monster: ObservableMonster(mode: mode, monster: monster),
                                spawn: monsterSpawn
                            )
                            spawnMonsters.append(spawnMonster)
                        }
                    }
                } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                    if let monster = try? await monsterDatabase.monster(forAegisName: monsterAegisName) {
                        if !monsters.contains(monster) {
                            monsters.append(monster)

                            let spawnMonster = SpawnMonster(
                                monster: ObservableMonster(mode: mode, monster: monster),
                                spawn: monsterSpawn
                            )
                            spawnMonsters.append(spawnMonster)
                        }
                    }
                }
            }
            self.spawnMonsters = spawnMonsters
        }
    }
}

extension ObservableMap: Hashable {
    static func == (lhs: ObservableMap, rhs: ObservableMap) -> Bool {
        lhs.map.name == rhs.map.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(map.name)
    }
}

extension ObservableMap: Identifiable {
    var id: String {
        map.name
    }
}
