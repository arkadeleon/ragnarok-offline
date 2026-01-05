//
//  ScriptCommands.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/1/5.
//

public struct ScriptCommands: Sendable {
    public var mapFlags: [MapFlag] = []
    public var monsterSpawns: [MonsterSpawn] = []
    public var warpPoints: [WarpPoint] = []
    public var npcs: [NPC] = []
    public var floatingNPCs: [FloatingNPC] = []
    public var shopNPCs: [ShopNPC] = []
    public var duplicates: [Duplicate] = []
    public var functions: [Function] = []

    public init() {
    }

    public func monsterSpawns(for monster: Monster) -> [MonsterSpawn] {
        let monsterSpawns = monsterSpawns.filter { monsterSpawn in
            monsterSpawn.monsterID == monster.id || monsterSpawn.monsterAegisName == monster.aegisName
        }
        return monsterSpawns
    }

    public func monsterSpawns(for monster: (id: Int, aegisName: String)) -> [MonsterSpawn] {
        let monsterSpawns = monsterSpawns.filter { monsterSpawn in
            monsterSpawn.monsterID == monster.id || monsterSpawn.monsterAegisName == monster.aegisName
        }
        return monsterSpawns
    }

    public func monsterSpawns(forMapName mapName: String) -> [MonsterSpawn] {
        let monsterSpawns = monsterSpawns.filter { monsterSpawn in
            monsterSpawn.mapName == mapName
        }
        return monsterSpawns
    }

    mutating func merge(_ other: ScriptCommands) {
        mapFlags += other.mapFlags
        monsterSpawns += other.monsterSpawns
        warpPoints += other.warpPoints
        npcs += other.npcs
        floatingNPCs += other.floatingNPCs
        shopNPCs += other.shopNPCs
        duplicates += other.duplicates
        functions += other.functions
    }
}
