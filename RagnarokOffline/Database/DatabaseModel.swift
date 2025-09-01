//
//  DatabaseModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/27.
//

import Foundation
import ROConstants
import RODatabase
import rAthenaResources

struct DropItem: Identifiable {
    var index: Int
    var drop: Monster.Drop
    var item: ItemModel

    var id: Int {
        index
    }
}

struct DroppingMonster: Identifiable {
    var monster: MonsterModel
    var drop: Monster.Drop

    var id: Int {
        monster.id
    }
}

struct SpawnMap: Identifiable {
    var map: MapModel
    var monsterSpawn: MonsterSpawn

    var id: String {
        map.name
    }
}

struct SpawningMonster: Identifiable {
    var monster: MonsterModel
    var spawn: MonsterSpawn

    var id: Int {
        monster.id
    }
}

@MainActor
@Observable
final class DatabaseModel {
    let mode: DatabaseMode

    var items: [ItemModel] = []
    var itemsByID: [Int : ItemModel] = [:]
    var itemsByAegisName: [String : ItemModel] = [:]

    var jobs: [JobModel] = []

    var maps: [MapModel] = []
    var mapsByName: [String: MapModel] = [:]

    var monsters: [MonsterModel] = []
    var monstersByID: [Int: MonsterModel] = [:]
    var monstersByAegisName: [String: MonsterModel] = [:]

    var monsterSummons: [MonsterSummonModel] = []
    var monsterSummonsByGroup: [String: MonsterSummonModel] = [:]

    var pets: [PetModel] = []

    var skills: [SkillModel] = []
    var skillsByID: [Int: SkillModel] = [:]
    var skillsByAegisName: [String: SkillModel] = [:]

    var statusChanges: [StatusChangeModel] = []
    var statusChangesByID: [StatusChangeID: StatusChangeModel] = [:]

    private let itemDatabase: ItemDatabase
    private let jobDatabase: JobDatabase
    private let mapDatabase: MapDatabase
    private let monsterDatabase: MonsterDatabase
    private let monsterSummonDatabase: MonsterSummonDatabase
    private let npcDatabase: NPCDatabase
    private let petDatabase: PetDatabase
    private let skillDatabase: SkillDatabase
    private let skillTreeDatabase: SkillTreeDatabase
    private let statusChangeDatabase: StatusChangeDatabase

    @ObservationIgnored private var itemDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var jobDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var mapDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterSummonDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var petDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var skillDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var statusChangeDatabaseTask: Task<Void, Never>?

    init(mode: DatabaseMode) {
        self.mode = mode

        let sourceURL = ServerResourceManager.shared.sourceURL
        itemDatabase = ItemDatabase(sourceURL: sourceURL, mode: mode)
        jobDatabase = JobDatabase(sourceURL: sourceURL, mode: mode)
        mapDatabase = MapDatabase(sourceURL: sourceURL, mode: mode)
        monsterDatabase = MonsterDatabase(sourceURL: sourceURL, mode: mode)
        monsterSummonDatabase = MonsterSummonDatabase(sourceURL: sourceURL, mode: mode)
        npcDatabase = NPCDatabase(sourceURL: sourceURL, mode: mode)
        petDatabase = PetDatabase(sourceURL: sourceURL, mode: mode)
        skillDatabase = SkillDatabase(sourceURL: sourceURL, mode: mode)
        skillTreeDatabase = SkillTreeDatabase(sourceURL: sourceURL, mode: mode)
        statusChangeDatabase = StatusChangeDatabase(sourceURL: sourceURL, mode: mode)
    }

    // MARK: - Item Database

    func fetchItems() async {
        if let itemDatabaseTask {
            return await itemDatabaseTask.value
        }

        let itemDatabaseTask = Task {
            let items = await itemDatabase.items()

            self.items = items.map { item in
                ItemModel(mode: mode, item: item)
            }

            for item in self.items {
                await item.fetchLocalizedName()
            }

            self.itemsByID = Dictionary(
                self.items.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.itemsByAegisName = Dictionary(
                self.items.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.itemDatabaseTask = itemDatabaseTask

        return await itemDatabaseTask.value
    }

    func item(forID id: Int) async -> ItemModel? {
        await fetchItems()
        return itemsByID[id]
    }

    func item(forAegisName aegisName: String) async -> ItemModel? {
        await fetchItems()
        return itemsByAegisName[aegisName]
    }

    func dropItems(for drops: [Monster.Drop]) async -> [DropItem] {
        var dropItems: [DropItem] = []

        await fetchItems()

        for (index, drop) in drops.enumerated() {
            if let item = await item(forAegisName: drop.item) {
                let dropItem = DropItem(index: index, drop: drop, item: item)
                dropItems.append(dropItem)
            }
        }

        return dropItems
    }

    // MARK: - Job Database

    func fetchJobs() async {
        if let jobDatabaseTask {
            return await jobDatabaseTask.value
        }

        let jobDatabaseTask = Task {
            let jobs = await jobDatabase.jobs()

            self.jobs = jobs.map { job in
                JobModel(mode: mode, job: job)
            }

            for job in self.jobs {
                await job.fetchLocalizedName()
            }
        }

        self.jobDatabaseTask = jobDatabaseTask

        return await jobDatabaseTask.value
    }

    // MARK: - Map Database

    func fetchMaps() async {
        if let mapDatabaseTask {
            return await mapDatabaseTask.value
        }

        let mapDatabaseTask = Task {
            let maps = await mapDatabase.maps()

            self.maps = maps.map { map in
                MapModel(mode: mode, map: map)
            }

            for map in self.maps {
                await map.fetchLocalizedName()
            }

            self.mapsByName = Dictionary(
                self.maps.map({ ($0.name, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.mapDatabaseTask = mapDatabaseTask

        return await mapDatabaseTask.value
    }

    func map(forName name: String) async -> MapModel? {
        await fetchMaps()
        return mapsByName[name]
    }

    func spawnMaps(for monster: (id: Int, aegisName: String)) async -> [SpawnMap] {
        var spawnMaps: [SpawnMap] = []

        let monsterSpawns = await npcDatabase.monsterSpawns(for: monster)
        for monsterSpawn in monsterSpawns {
            if let map = await map(forName: monsterSpawn.mapName) {
                if !spawnMaps.contains(where: { $0.map.name == map.name }) {
                    let spawnMap = SpawnMap(map: map, monsterSpawn: monsterSpawn)
                    spawnMaps.append(spawnMap)
                }
            }
        }

        return spawnMaps
    }

    // MARK: - Monster Database

    func fetchMonsters() async {
        if let monsterDatabaseTask {
            return await monsterDatabaseTask.value
        }

        let monsterDatabaseTask = Task {
            let monsters = await monsterDatabase.monsters()

            self.monsters = monsters.map { monster in
                MonsterModel(mode: mode, monster: monster)
            }

            for monster in self.monsters {
                await monster.fetchLocalizedName()
            }

            self.monstersByID = Dictionary(
                self.monsters.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.monstersByAegisName = Dictionary(
                self.monsters.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.monsterDatabaseTask = monsterDatabaseTask

        return await monsterDatabaseTask.value
    }

    func monster(forID id: Int) async -> MonsterModel? {
        await fetchMonsters()
        return monstersByID[id]
    }

    func monster(forAegisName aegisName: String) async -> MonsterModel? {
        await fetchMonsters()
        return monstersByAegisName[aegisName]
    }

    func droppingMonsters(forItemAegisName itemAegisName: String) async -> [DroppingMonster] {
        var droppingMonsters: [DroppingMonster] = []

        await fetchMonsters()

        for monster in monsters {
            let drops = (monster.mvpDrops ?? []) + (monster.drops ?? [])
            for drop in drops {
                if drop.item == itemAegisName {
                    let droppingMonster = DroppingMonster(monster: monster, drop: drop)
                    droppingMonsters.append(droppingMonster)
                    break
                }
            }
        }

        return droppingMonsters
    }

    func spawningMonsters(forMapName mapName: String) async -> [SpawningMonster] {
        var spawningMonsters: [SpawningMonster] = []
        var monsters: [MonsterModel] = []

        let monsterSpawns = await npcDatabase.monsterSpawns(forMapName: mapName)
        for monsterSpawn in monsterSpawns {
            if let monsterID = monsterSpawn.monsterID {
                if let monster = await monster(forID: monsterID) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawningMonster = SpawningMonster(monster: monster, spawn: monsterSpawn)
                        spawningMonsters.append(spawningMonster)
                    }
                }
            } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                if let monster = await monster(forAegisName: monsterAegisName) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawningMonster = SpawningMonster(monster: monster, spawn: monsterSpawn)
                        spawningMonsters.append(spawningMonster)
                    }
                }
            }
        }

        return spawningMonsters
    }

    // MARK: - Monster Summon Database

    func fetchMonsterSummons() async {
        if let monsterSummonDatabaseTask {
            return await monsterSummonDatabaseTask.value
        }

        let monsterSummonDatabaseTask = Task {
            let summons = await monsterSummonDatabase.monsterSummons()

            self.monsterSummons = summons.map { summon in
                MonsterSummonModel(mode: mode, monsterSummon: summon)
            }

            self.monsterSummonsByGroup = Dictionary(
                self.monsterSummons.map({ ($0.group, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.monsterSummonDatabaseTask = monsterSummonDatabaseTask

        return await monsterSummonDatabaseTask.value
    }

    func monsterSummon(forGroup group: String) async -> MonsterSummonModel? {
        await fetchMonsterSummons()
        return monsterSummonsByGroup[group]
    }

    // MARK: - Pet Database

    func fetchPets() async {
        if let petDatabaseTask {
            return await petDatabaseTask.value
        }

        let petDatabaseTask = Task {
            await fetchMonsters()

            let pets = await petDatabase.pets()

            self.pets = pets.map { pet in
                PetModel(mode: mode, pet: pet)
            }

            for pet in self.pets {
                pet.monster = await monster(forAegisName: pet.aegisName)
            }
        }

        self.petDatabaseTask = petDatabaseTask

        return await petDatabaseTask.value
    }

    // MARK: - Skill Database

    func fetchSkills() async {
        if let skillDatabaseTask {
            return await skillDatabaseTask.value
        }

        let skillDatabaseTask = Task {
            let skills = await skillDatabase.skills()

            self.skills = skills.map { skill in
                SkillModel(mode: mode, skill: skill)
            }

            for skill in self.skills {
                await skill.fetchLocalizedName()
            }

            self.skillsByID = Dictionary(
                self.skills.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.skillsByAegisName = Dictionary(
                self.skills.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.skillDatabaseTask = skillDatabaseTask

        return await skillDatabaseTask.value
    }

    func skill(forID id: Int) async -> SkillModel? {
        await fetchSkills()
        return skillsByID[id]
    }

    func skill(forAegisName aegisName: String) async -> SkillModel? {
        await fetchSkills()
        return skillsByAegisName[aegisName]
    }

    func skills(for jobID: JobID) async -> [SkillModel] {
        guard let tree = await skillTreeDatabase.skillTree(for: jobID)?.tree else {
            return []
        }

        var skills: [SkillModel] = []
        for skillInTree in tree {
            if let skill = await skill(forAegisName: skillInTree.name) {
                skills.append(skill)
            }
        }
        return skills
    }

    // MARK: - Status Change Database

    func fetchStatusChanges() async {
        if let statusChangeDatabaseTask {
            return await statusChangeDatabaseTask.value
        }

        let statusChangeDatabaseTask = Task {
            let statusChanges = await statusChangeDatabase.statusChanges()

            self.statusChanges = statusChanges.map { statusChange in
                StatusChangeModel(mode: mode, statusChange: statusChange)
            }

            self.statusChangesByID = Dictionary(
                self.statusChanges.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.statusChangeDatabaseTask = statusChangeDatabaseTask

        return await statusChangeDatabaseTask.value
    }

    func statusChange(for statusChangeID: StatusChangeID) async -> StatusChangeModel? {
        await fetchStatusChanges()
        return statusChangesByID[statusChangeID]
    }

    func statusChanges(for statusChangeIDs: [StatusChangeID]) async -> [StatusChangeModel] {
        await fetchStatusChanges()
        return statusChangeIDs.compactMap {
            statusChangesByID[$0]
        }
    }
}
