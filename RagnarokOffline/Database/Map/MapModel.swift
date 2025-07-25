//
//  MapModel.swift
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
final class MapModel {
    struct SpawningMonster: Identifiable {
        var monster: MonsterModel
        var spawn: MonsterSpawn

        var id: Int {
            monster.id
        }
    }

    private let mode: DatabaseMode
    private let map: Map

    private var localizedName: String?

    var image: CGImage?
    var spawningMonsters: [SpawningMonster] = []

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

    func fetchLocalizedName() async {
        let mapNameTable = await ResourceManager.shared.mapNameTable(for: .current)
        self.localizedName = mapNameTable.localizedMapName(forMapName: map.name)
    }

    @MainActor
    func fetchImage() async {
        if image == nil {
            let scriptContext = await ResourceManager.shared.scriptContext(for: .current)
            let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
            let path = pathGenerator.generateMapImagePath(mapName: map.name)
            image = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
        }
    }

    @MainActor
    func fetchDetail(monsterDatabase: DatabaseModel<MonsterProvider>) async {
        await fetchImage()

        let npcDatabase = NPCDatabase.shared

        await monsterDatabase.fetchRecords()

        let monsterSpawns = await npcDatabase.monsterSpawns(forMapName: map.name)
        var spawningMonsters: [SpawningMonster] = []
        var monsters: [MonsterModel] = []
        for monsterSpawn in monsterSpawns {
            if let monsterID = monsterSpawn.monsterID {
                if let monster = monsterDatabase.monster(forID: monsterID) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawningMonster = SpawningMonster(monster: monster, spawn: monsterSpawn)
                        spawningMonsters.append(spawningMonster)
                    }
                }
            } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                if let monster = monsterDatabase.monster(forAegisName: monsterAegisName) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawningMonster = SpawningMonster(monster: monster, spawn: monsterSpawn)
                        spawningMonsters.append(spawningMonster)
                    }
                }
            }
        }
        self.spawningMonsters = spawningMonsters
    }
}

extension MapModel: Equatable {
    static func == (lhs: MapModel, rhs: MapModel) -> Bool {
        lhs.map.name == rhs.map.name
    }
}

extension MapModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(map.name)
    }
}

extension MapModel: Identifiable {
    var id: String {
        map.name
    }
}
