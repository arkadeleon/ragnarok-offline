//
//  ObservableMap.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/7.
//

import CoreGraphics
import Observation
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

    private let localizedName: String?

    var image: CGImage?
    var spawnMonsters: [SpawnMonster] = []

    var displayName: String {
        localizedName ?? map.name
    }

    init(mode: DatabaseMode, map: Map) {
        self.mode = mode
        self.map = map

        self.localizedName = MapNameTable.current.localizedMapName(forMapName: map.name)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Map, Value>) -> Value {
        map[keyPath: keyPath]
    }

    @MainActor
    func fetchImage() async {
        if image == nil {
            let pathGenerator = ResourcePathGenerator(scriptManager: .shared)
            let path = pathGenerator.generateMapImagePath(mapName: map.name)
            image = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
        }
    }

    @MainActor
    func fetchDetail() async {
        await fetchImage()

        let monsterDatabase = MonsterDatabase.shared
        let npcDatabase = NPCDatabase.shared

        let monsterSpawns = await npcDatabase.monsterSpawns(forMapName: map.name)
        var spawnMonsters: [SpawnMonster] = []
        var monsters: [Monster] = []
        for monsterSpawn in monsterSpawns {
            if let monsterID = monsterSpawn.monsterID {
                if let monster = await monsterDatabase.monster(forID: monsterID) {
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
                if let monster = await monsterDatabase.monster(forAegisName: monsterAegisName) {
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
