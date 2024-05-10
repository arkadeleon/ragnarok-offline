//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/20.
//

import rAthenaCommon

public enum DatabaseError: Error {
    case recordNotFound
}

public final class Database: Sendable {
    public static let prerenewal = Database(mode: .prerenewal)
    public static let renewal = Database(mode: .renewal)

    public static func database(for mode: ServerMode) -> Database {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private let scriptCache: ScriptCache

    private init(mode: ServerMode) {
        self.mode = mode

        scriptCache = ScriptCache(mode: mode)
    }

    // MARK: - Script

    public func monsterSpawns(forMonster monster: Monster) async throws -> [MonsterSpawn] {
        try await scriptCache.restoreScripts()
        let monsterSpawns = await scriptCache.monsterSpawns.filter { monsterSpawn in
            monsterSpawn.monsterID == monster.id || monsterSpawn.monsterAegisName == monster.aegisName
        }
        return monsterSpawns
    }

    public func monsterSpawns(forMap map: Map) async throws -> [MonsterSpawn] {
        try await scriptCache.restoreScripts()
        let monsterSpawns = await scriptCache.monsterSpawns.filter { monsterSpawn in
            monsterSpawn.mapName == map.name
        }
        return monsterSpawns
    }
}
