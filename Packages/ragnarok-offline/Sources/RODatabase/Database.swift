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

    private let itemCache: ItemCache
    private let jobCache: JobCache
    private let skillCache: SkillCache
    private let skillTreeCache: SkillTreeCache
    private let mapCache: MapCache
    private let scriptCache: ScriptCache

    private init(mode: ServerMode) {
        self.mode = mode

        itemCache = ItemCache(mode: mode)
        jobCache = JobCache(mode: mode)
        skillCache = SkillCache(mode: mode)
        skillTreeCache = SkillTreeCache(mode: mode)
        mapCache = MapCache(mode: mode)
        scriptCache = ScriptCache(mode: mode)
    }

    // MARK: - Item

    public func usableItems() async throws -> [Item] {
        try await itemCache.restoreUsableItems()
        let usableItems = await itemCache.usableItems
        return usableItems
    }

    public func equipItems() async throws -> [Item] {
        try await itemCache.restoreEquipItems()
        let equipItems = await itemCache.equipItems
        return equipItems
    }

    public func etcItems() async throws -> [Item] {
        try await itemCache.restoreEtcItems()
        let etcItems = await itemCache.etcItems
        return etcItems
    }

    public func items() async throws -> [Item] {
        try await itemCache.restoreItems()
        let items = await itemCache.items
        return items
    }

    public func item(forAegisName aegisName: String) async throws -> Item {
        try await itemCache.restoreItems()
        if let item = await itemCache.itemsByAegisNames[aegisName] {
            return item
        } else {
            throw DatabaseError.recordNotFound
        }
    }

    // MARK: - Job

    public func jobs() async throws -> [JobStats] {
        try await jobCache.restoreJobs()
        let jobs = await jobCache.jobs
        return jobs
    }

    // MARK: - Skill

    public func skills() async throws -> [Skill] {
        try await skillCache.restoreSkills()
        let skills = await skillCache.skills
        return skills
    }

    public func skill(forAegisName aegisName: String) async throws -> Skill {
        try await skillCache.restoreSkills()
        if let skill = await skillCache.skillsByAegisNames[aegisName] {
            return skill
        } else {
            throw DatabaseError.recordNotFound
        }
    }

    // MARK: - Skill Tree

    public func skillTrees() async throws -> [SkillTree] {
        try await skillTreeCache.restoreSkillTrees()
        let skillTrees = await skillTreeCache.skillTrees
        return skillTrees
    }

    public func skillTree(forJobID jobID: Int) async throws -> SkillTree {
        try await skillTreeCache.restoreSkillTrees()
        if let skillTree = await skillTreeCache.skillTreesByJobIDs[jobID] {
            return skillTree
        } else {
            throw DatabaseError.recordNotFound
        }
    }

    // MARK: - Map

    public func maps() async throws -> [Map] {
        try await mapCache.restoreMaps()
        let maps = await mapCache.maps
        return maps
    }

    public func map(forName name: String) async throws -> Map {
        try await mapCache.restoreMaps()
        if let map = await mapCache.mapsByNames[name] {
            return map
        } else {
            throw DatabaseError.recordNotFound
        }
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
