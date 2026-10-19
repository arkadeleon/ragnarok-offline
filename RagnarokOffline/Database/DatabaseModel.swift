//
//  DatabaseModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/8/27.
//

import Foundation
import RagnarokConstants
import RagnarokDatabase
import RagnarokLocalization
import RagnarokResources
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
    var isMVPDrop: Bool

    var id: String {
        isMVPDrop ? "\(monster.id)-mvp" : "\(monster.id)"
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

struct SellingShop: Identifiable {
    var shopNPC: ShopNPC
    var map: MapModel
    var price: Int

    var id: String {
        shopNPC.npcName
    }

    var npcDisplayName: String {
        String(shopNPC.npcName.prefix { $0 != "#" && $0 != ":" })
    }
}

@MainActor
@Observable
final class DatabaseModel {
    let mode: DatabaseMode
    let resourceManager: ResourceManager

    var items: [ItemModel] = []
    var itemsByID: [Int : ItemModel] = [:]
    var itemsByAegisName: [String : ItemModel] = [:]
    var itemSearchIndex = DatabaseSearchIndex()

    var jobs: [JobModel] = []
    var jobSearchIndex = DatabaseSearchIndex()

    var maps: [MapModel] = []
    var mapsByName: [String: MapModel] = [:]
    var mapSearchIndex = DatabaseSearchIndex()

    var monsters: [MonsterModel] = []
    var monstersByID: [Int: MonsterModel] = [:]
    var monstersByAegisName: [String: MonsterModel] = [:]
    var monsterSearchIndex = DatabaseSearchIndex()

    var monsterSummons: [MonsterSummonModel] = []
    var monsterSummonsByGroup: [String: MonsterSummonModel] = [:]
    var monsterSummonSearchIndex = DatabaseSearchIndex()

    var pets: [PetModel] = []
    var petSearchIndex = DatabaseSearchIndex()

    var skills: [SkillModel] = []
    var skillsByID: [Int: SkillModel] = [:]
    var skillsByAegisName: [String: SkillModel] = [:]
    var skillSearchIndex = DatabaseSearchIndex()

    var statusChanges: [StatusChangeModel] = []
    var statusChangesByID: [StatusChangeID: StatusChangeModel] = [:]
    var statusChangeSearchIndex = DatabaseSearchIndex()

    var scriptCommands = ScriptCommands()

    private let itemInfoTable: ItemInfoTable
    private let mapInfoTable: MapInfoTable
    private let messageStringTable: MessageStringTable
    private let monsterNameTable: MonsterNameTable
    private let skillInfoTable: SkillInfoTable
    private let statusInfoTable: StatusInfoTable

    @ObservationIgnored private var itemDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var jobDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var mapDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterSummonDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var petDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var skillDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var statusChangeDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var npcDatabaseTask: Task<Void, Never>?

    init(mode: DatabaseMode, resourceManager: ResourceManager) {
        self.mode = mode
        self.resourceManager = resourceManager

        itemInfoTable = ItemInfoTable()
        mapInfoTable = MapInfoTable()
        messageStringTable = MessageStringTable()
        monsterNameTable = MonsterNameTable()
        skillInfoTable = SkillInfoTable()
        statusInfoTable = StatusInfoTable()
    }

    // MARK: - Item Database

    func fetchItems() async {
        if let itemDatabaseTask {
            return await itemDatabaseTask.value
        }

        let itemDatabaseTask = Task {
            let itemDatabase = ItemDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let items: [Item]
            do {
                items = try await itemDatabase.items()
            } catch {
                logger.warning("Item database task failed: \(error)")
                return
            }

            self.items = items.map { item in
                let localizedName = itemInfoTable.localizedIdentifiedItemName(forItemID: item.id)
                let localizedDescription = itemInfoTable.localizedIdentifiedItemDescription(forItemID: item.id)
                let model = ItemModel(mode: mode, item: item, localizedName: localizedName, localizedDescription: localizedDescription, resourceManager: resourceManager)
                return model
            }

            self.itemsByID = Dictionary(
                self.items.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.itemsByAegisName = Dictionary(
                self.items.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.itemSearchIndex = DatabaseSearchIndex(self.items) {
                ["#\($0.id)", $0.aegisName, $0.name, $0.localizedName].compactMap({ $0 })
            }
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
            let jobDatabase = JobDatabase(baseURL: serverResourceBaseURL, mode: mode)
            let skillTreeDatabase = SkillTreeDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let jobs: [Job]
            let skillTrees: [SkillTree]
            do {
                jobs = try await jobDatabase.jobs()
                skillTrees = try await skillTreeDatabase.skillTrees()
            } catch {
                logger.warning("Job database task failed: \(error)")
                return
            }

            self.jobs = jobs.map { job in
                let localizedName = job.id.localizedName.map { String(localized: $0) }
                let skillTree = skillTrees.first(where: { $0.job == job.id })
                let model = JobModel(mode: mode, job: job, localizedName: localizedName, skillTree: skillTree, resourceManager: resourceManager)
                return model
            }

            self.jobSearchIndex = DatabaseSearchIndex(self.jobs) {
                [$0.id.stringValue, $0.localizedName].compactMap({ $0 })
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
            let mapDatabase = MapDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let maps: [Map]
            do {
                maps = try await mapDatabase.maps()
            } catch {
                logger.warning("Map database task failed: \(error)")
                return
            }

            self.maps = maps.map { map in
                let localizedName = mapInfoTable.localizedMapName(forMapName: map.name)
                let model = MapModel(mode: mode, map: map, localizedName: localizedName, resourceManager: resourceManager)
                return model
            }

            self.mapsByName = Dictionary(
                self.maps.map({ ($0.name, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.mapSearchIndex = DatabaseSearchIndex(self.maps) {
                [$0.name, $0.localizedName].compactMap({ $0 })
            }
        }

        self.mapDatabaseTask = mapDatabaseTask

        return await mapDatabaseTask.value
    }

    func map(forName name: String) async -> MapModel? {
        await fetchMaps()
        return mapsByName[name]
    }

    // MARK: - Monster Database

    func fetchMonsters() async {
        if let monsterDatabaseTask {
            return await monsterDatabaseTask.value
        }

        let monsterDatabaseTask = Task {
            let monsterDatabase = MonsterDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let monsters: [Monster]
            do {
                monsters = try await monsterDatabase.monsters()
            } catch {
                logger.warning("Monster database task failed: \(error)")
                return
            }

            self.monsters = monsters.map { monster in
                let localizedName = monsterNameTable.localizedMonsterName(forMonsterID: monster.id)
                let model = MonsterModel(mode: mode, monster: monster, localizedName: localizedName, resourceManager: resourceManager)
                return model
            }

            self.monstersByID = Dictionary(
                self.monsters.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.monstersByAegisName = Dictionary(
                self.monsters.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.monsterSearchIndex = DatabaseSearchIndex(self.monsters) {
                ["#\($0.id)", $0.aegisName, $0.name, $0.localizedName].compactMap({ $0 })
            }
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
            if let drop = monster.mvpDrops?.first(where: { $0.item == itemAegisName }) {
                let droppingMonster = DroppingMonster(monster: monster, drop: drop, isMVPDrop: true)
                droppingMonsters.append(droppingMonster)
            }

            if let drop = monster.drops?.first(where: { $0.item == itemAegisName }) {
                let droppingMonster = DroppingMonster(monster: monster, drop: drop, isMVPDrop: false)
                droppingMonsters.append(droppingMonster)
            }
        }

        return droppingMonsters.sorted(using: KeyPathComparator(\.drop.rate, order: .reverse))
    }

    // MARK: - Monster Summon Database

    func fetchMonsterSummons() async {
        if let monsterSummonDatabaseTask {
            return await monsterSummonDatabaseTask.value
        }

        let monsterSummonDatabaseTask = Task {
            let monsterSummonDatabase = MonsterSummonDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let monsterSummons: [MonsterSummon]
            do {
                monsterSummons = try await monsterSummonDatabase.monsterSummons()
            } catch {
                logger.warning("Monster summon database task failed: \(error)")
                return
            }

            self.monsterSummons = monsterSummons.map { summon in
                MonsterSummonModel(mode: mode, monsterSummon: summon)
            }

            self.monsterSummonsByGroup = Dictionary(
                self.monsterSummons.map({ ($0.group, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.monsterSummonSearchIndex = DatabaseSearchIndex(self.monsterSummons) {
                [$0.displayName]
            }
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

            let petDatabase = PetDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let pets: [Pet]
            do {
                pets = try await petDatabase.pets()
            } catch {
                logger.warning("Pet database task failed: \(error)")
                return
            }

            self.pets = pets.map { pet in
                PetModel(mode: mode, pet: pet)
            }

            for pet in self.pets {
                pet.monster = await monster(forAegisName: pet.aegisName)
            }

            self.petSearchIndex = DatabaseSearchIndex(self.pets) {
                [$0.aegisName, $0.monster?.name, $0.monster?.localizedName].compactMap({ $0 })
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
            let skillDatabase = SkillDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let skills: [Skill]
            do {
                skills = try await skillDatabase.skills()
            } catch {
                logger.warning("Skill database task failed: \(error)")
                return
            }

            self.skills = skills.map { skill in
                let localizedName = skillInfoTable.localizedSkillName(forSkillID: skill.id)
                let localizedDescription = skillInfoTable.localizedSkillDescription(forSkillID: skill.id)
                let model = SkillModel(mode: mode, skill: skill, localizedName: localizedName, localizedDescription: localizedDescription, resourceManager: resourceManager)
                return model
            }

            self.skillsByID = Dictionary(
                self.skills.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.skillsByAegisName = Dictionary(
                self.skills.map({ ($0.aegisName, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.skillSearchIndex = DatabaseSearchIndex(self.skills) {
                ["#\($0.id)", $0.aegisName, $0.name, $0.localizedName].compactMap({ $0 })
            }
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
        await fetchJobs()

        guard let tree = jobs.first(where: { $0.id == jobID })?.skillTree?.tree else {
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
            let statusChangeDatabase = StatusChangeDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let statusChanges: [StatusChange]
            do {
                statusChanges = try await statusChangeDatabase.statusChanges()
            } catch {
                logger.warning("Status change database task failed: \(error)")
                return
            }

            self.statusChanges = statusChanges.map { statusChange in
                let lines = statusInfoTable.localizedStatusDescription(forStatusID: statusChange.icon.rawValue)?.lines ?? []
                let hasName = lines.first.map({ $0.text != "%s" }) ?? false
                let localizedName = hasName ? lines.first?.text : nil
                let localizedDescription = lines.dropFirst(hasName ? 1 : 0)
                    .filter({ $0.text != "%s" })
                    .map(\.text)
                    .joined(separator: "\n")
                let model = StatusChangeModel(
                    mode: mode,
                    statusChange: statusChange,
                    localizedName: localizedName,
                    localizedDescription: localizedDescription.isEmpty ? nil : localizedDescription,
                    resourceManager: resourceManager
                )
                return model
            }

            self.statusChangesByID = Dictionary(
                self.statusChanges.map({ ($0.id, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            self.statusChangeSearchIndex = DatabaseSearchIndex(self.statusChanges) {
                [$0.status.stringValue, $0.localizedName].compactMap({ $0 })
            }
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

    // MARK: - NPC Database

    func fetchScriptCommands() async {
        if let npcDatabaseTask {
            return await npcDatabaseTask.value
        }

        let npcDatabaseTask = Task {
            let npcDatabase = NPCDatabase(baseURL: serverResourceBaseURL, mode: mode)

            do {
                scriptCommands = try await npcDatabase.scriptCommands()
            } catch {
                logger.warning("NPC database task failed: \(error)")
            }
        }

        self.npcDatabaseTask = npcDatabaseTask

        return await npcDatabaseTask.value
    }

    func spawnMaps(for monster: (id: Int, aegisName: String)) async -> [SpawnMap] {
        await fetchScriptCommands()

        var spawnMaps: [SpawnMap] = []

        let monsterSpawns = scriptCommands.monsterSpawns(for: monster)
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

    func spawningMonsters(forMapName mapName: String) async -> [SpawningMonster] {
        await fetchScriptCommands()

        var spawningMonsters: [SpawningMonster] = []
        var monsters: [MonsterModel] = []

        let monsterSpawns = scriptCommands.monsterSpawns(forMapName: mapName)
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

    func sellingShops(for item: ItemModel) async -> [SellingShop] {
        await fetchScriptCommands()

        var sellingShops: [SellingShop] = []

        for shopNPC in scriptCommands.shopNPCs(forItemID: item.id) {
            guard let mapName = shopNPC.mapName,
                  let map = await map(forName: mapName),
                  let shopItem = shopNPC.items.first(where: { $0.itemID == item.id }) else {
                continue
            }

            let price = shopItem.price == -1 ? item.buy : shopItem.price
            let sellingShop = SellingShop(shopNPC: shopNPC, map: map, price: price)
            sellingShops.append(sellingShop)
        }

        return sellingShops
    }
}
