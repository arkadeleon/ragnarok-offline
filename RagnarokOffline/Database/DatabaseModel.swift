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

@MainActor
@Observable
final class DatabaseModel {
    let mode: DatabaseMode
    let resourceManager: ResourceManager

    var items: [ItemModel] = []
    var itemsByID: [Int : ItemModel] = [:]
    var itemsByAegisName: [String : ItemModel] = [:]
    var itemSearchIndex = DatabaseSearchIndex()

    var itemCombosByItemAegisName: [String : [ItemModel.ItemCombo]] = [:]
    var itemGroupsByGroupName: [String : ItemGroupModel] = [:]

    var jobs: [JobModel] = []
    var jobSearchIndex = DatabaseSearchIndex()

    var maps: [MapModel] = []
    var mapsByName: [String : MapModel] = [:]
    var mapSearchIndex = DatabaseSearchIndex()

    var monsters: [MonsterModel] = []
    var monstersByID: [Int : MonsterModel] = [:]
    var monstersByAegisName: [String : MonsterModel] = [:]
    var monsterSearchIndex = DatabaseSearchIndex()

    var monsterSkillsByMonsterID: [Int : [MonsterSkill]] = [:]
    var monsterSummonsByGroup: [String : MonsterSummonModel] = [:]

    var pets: [PetModel] = []
    var petsByMonsterAegisName: [String : PetModel] = [:]

    var skills: [SkillModel] = []
    var skillsByID: [Int : SkillModel] = [:]
    var skillsByAegisName: [String : SkillModel] = [:]
    var skillSearchIndex = DatabaseSearchIndex()

    var statusChanges: [StatusChangeModel] = []
    var statusChangesByID: [StatusChangeID : StatusChangeModel] = [:]
    var statusChangeSearchIndex = DatabaseSearchIndex()

    var elementalAttributeDamageAdjustments: [ElementalAttributeDamageAdjustment] = []

    var scriptCommands = ScriptCommands()
    var shopNPCsByUniqueName: [String : ShopNPC] = [:]
    var npcCodesByUniqueName: [String : String] = [:]

    private let itemInfoTable: ItemInfoTable
    private let mapInfoTable: MapInfoTable
    private let messageStringTable: MessageStringTable
    private let monsterNameTable: MonsterNameTable
    private let skillInfoTable: SkillInfoTable
    private let statusInfoTable: StatusInfoTable

    @ObservationIgnored private var itemDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var itemComboDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var itemGroupDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var jobDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var mapDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterSkillDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var monsterSummonDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var petDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var skillDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var statusChangeDatabaseTask: Task<Void, Never>?
    @ObservationIgnored private var elementalAttributeDamageAdjustmentDatabaseTask: Task<Void, Never>?
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

    func dropItems(for drops: [Monster.Drop]) async -> [MonsterModel.DropItem] {
        await fetchItems()

        var dropItems: [MonsterModel.DropItem] = []

        for (index, drop) in drops.enumerated() {
            if let item = await item(forAegisName: drop.item) {
                let dropItem = MonsterModel.DropItem(index: index, drop: drop, item: item)
                dropItems.append(dropItem)
            }
        }

        return dropItems
    }

    // MARK: - Item Combo Database

    func fetchItemCombos() async {
        if let itemComboDatabaseTask {
            return await itemComboDatabaseTask.value
        }

        let itemComboDatabaseTask = Task {
            await fetchItems()

            let itemComboDatabase = ItemComboDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let itemCombos: [ItemCombo]
            do {
                itemCombos = try await itemComboDatabase.itemCombos()
            } catch {
                logger.warning("Item combo database task failed: \(error)")
                return
            }

            var itemCombosByItemAegisName: [String : [ItemModel.ItemCombo]] = [:]

            let combos = itemCombos.flatMap { itemCombo in
                itemCombo.combos.map({ ($0, itemCombo.script) })
            }
            for (index, (combo, script)) in combos.enumerated() {
                let items = combo.combo.compactMap({ itemsByAegisName[$0] })
                let itemCombo = ItemModel.ItemCombo(id: index, items: items, script: script)
                for item in items {
                    itemCombosByItemAegisName[item.aegisName, default: []].append(itemCombo)
                }
            }

            self.itemCombosByItemAegisName = itemCombosByItemAegisName
        }

        self.itemComboDatabaseTask = itemComboDatabaseTask

        return await itemComboDatabaseTask.value
    }

    func itemCombos(forItemAegisName itemAegisName: String) async -> [ItemModel.ItemCombo] {
        await fetchItemCombos()

        return itemCombosByItemAegisName[itemAegisName] ?? []
    }

    // MARK: - Item Group Database

    func fetchItemGroups() async {
        if let itemGroupDatabaseTask {
            return await itemGroupDatabaseTask.value
        }

        let itemGroupDatabaseTask = Task {
            await fetchItems()

            let itemGroupDatabase = ItemGroupDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let itemGroups: [ItemGroup]
            do {
                itemGroups = try await itemGroupDatabase.itemGroups()
            } catch {
                logger.warning("Item group database task failed: \(error)")
                return
            }

            let itemGroupsByGroupName = Dictionary(
                itemGroups.map({ ($0.group.uppercased(), ItemGroupModel(mode: mode, itemGroup: $0)) }),
                uniquingKeysWith: { (first, _) in first }
            )

            let items = items.map({ $0[dynamicMember: \.self] })
            let sourceItemIDs = await itemGroupDatabase.sourceItemIDs(in: items)
            for (groupName, itemIDs) in sourceItemIDs {
                itemGroupsByGroupName[groupName]?.sourceItems = itemIDs.compactMap({ itemsByID[$0] })
            }

            self.itemGroupsByGroupName = itemGroupsByGroupName
        }

        self.itemGroupDatabaseTask = itemGroupDatabaseTask

        return await itemGroupDatabaseTask.value
    }

    func itemGroup(forGroupName groupName: String) async -> ItemGroupModel? {
        await fetchItemGroups()

        return itemGroupsByGroupName[groupName.uppercased()]
    }

    func itemGroups(for item: ItemModel) async -> [ItemGroupModel] {
        guard let script = item.script else {
            return []
        }

        var itemGroups: [ItemGroupModel] = []

        for match in script.matches(of: /getgroupitem\(IG_([A-Za-z0-9_]+)/) {
            if let itemGroup = await itemGroup(forGroupName: String(match.1)), !itemGroups.contains(itemGroup) {
                itemGroups.append(itemGroup)
            }
        }

        return itemGroups
    }

    func obtainSources(forItemAegisName itemAegisName: String) async -> [ItemModel.ObtainSource] {
        await fetchItemGroups()

        var obtainSources: [ItemModel.ObtainSource] = []

        for itemGroup in itemGroupsByGroupName.values {
            guard let subGroupListItemChance = itemGroup.highestSubGroupListItemChance(forItemAegisName: itemAegisName) else {
                continue
            }
            for item in itemGroup.sourceItems {
                let obtainSource = ItemModel.ObtainSource(item: item, itemGroup: itemGroup, subGroupListItemChance: subGroupListItemChance)
                obtainSources.append(obtainSource)
            }
        }

        return obtainSources.sorted(using: [KeyPathComparator(\.subGroupListItemChance.probability, order: .reverse), KeyPathComparator(\.item.id)])
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

    func dropSources(forItemAegisName itemAegisName: String) async -> [ItemModel.DropSource] {
        await fetchMonsters()

        var dropSources: [ItemModel.DropSource] = []

        for monster in monsters {
            if let drop = monster.mvpDrops?.first(where: { $0.item == itemAegisName }) {
                let dropSource = ItemModel.DropSource(monster: monster, drop: drop, isMVPDrop: true)
                dropSources.append(dropSource)
            }

            if let drop = monster.drops?.first(where: { $0.item == itemAegisName }) {
                let dropSource = ItemModel.DropSource(monster: monster, drop: drop, isMVPDrop: false)
                dropSources.append(dropSource)
            }
        }

        return dropSources.sorted(using: KeyPathComparator(\.drop.rate, order: .reverse))
    }

    // MARK: - Monster Skill Database

    func fetchMonsterSkills() async {
        if let monsterSkillDatabaseTask {
            return await monsterSkillDatabaseTask.value
        }

        let monsterSkillDatabaseTask = Task {
            let monsterSkillDatabase = MonsterSkillDatabase(baseURL: serverResourceBaseURL, mode: mode)

            do {
                let monsterSkills = try await monsterSkillDatabase.monsterSkills()
                monsterSkillsByMonsterID = Dictionary(grouping: monsterSkills, by: \.monsterID)
            } catch {
                logger.warning("Monster skill database task failed: \(error)")
            }
        }

        self.monsterSkillDatabaseTask = monsterSkillDatabaseTask

        return await monsterSkillDatabaseTask.value
    }

    func castSkills(for monster: MonsterModel) async -> [MonsterModel.CastSkill] {
        await fetchMonsterSkills()
        await fetchSkills()

        var castSkills: [MonsterModel.CastSkill] = []

        let monsterSkills = monsterSkillsByMonsterID[monster.id, default: []]
        for (index, monsterSkill) in monsterSkills.enumerated() {
            let isDuplicate = castSkills.contains { castSkill in
                castSkill.monsterSkill.skillID == monsterSkill.skillID &&
                castSkill.monsterSkill.skillLevel == monsterSkill.skillLevel &&
                castSkill.monsterSkill.rate == monsterSkill.rate
            }
            if isDuplicate {
                continue
            }

            if let skill = skillsByID[monsterSkill.skillID] {
                let castSkill = MonsterModel.CastSkill(index: index, monsterSkill: monsterSkill, skill: skill)
                castSkills.append(castSkill)
            }
        }

        return castSkills
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

            self.monsterSummonsByGroup = Dictionary(
                monsterSummons.map({ ($0.group.uppercased(), MonsterSummonModel(mode: mode, monsterSummon: $0)) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.monsterSummonDatabaseTask = monsterSummonDatabaseTask

        return await monsterSummonDatabaseTask.value
    }

    func monsterSummon(forGroup group: String) async -> MonsterSummonModel? {
        await fetchMonsterSummons()

        return monsterSummonsByGroup[group.uppercased()]
    }

    func monsterSummon(for item: ItemModel) async -> MonsterSummonModel? {
        guard let match = item.script?.firstMatch(of: /MOBG_([A-Z_]+)/) else {
            return nil
        }

        return await monsterSummon(forGroup: String(match.1))
    }

    func monsterSummon(for skill: SkillModel) async -> MonsterSummonModel? {
        switch skill.aegisName {
        case "SA_CLASSCHANGE":
            await monsterSummon(forGroup: "CLASSCHANGE")
        case "TK_MISSION":
            await monsterSummon(forGroup: "TAEKWON_MISSION")
        default:
            nil
        }
    }

    // MARK: - Pet Database

    func fetchPets() async {
        if let petDatabaseTask {
            return await petDatabaseTask.value
        }

        let petDatabaseTask = Task {
            let petDatabase = PetDatabase(baseURL: serverResourceBaseURL, mode: mode)

            let pets: [Pet]
            do {
                pets = try await petDatabase.pets()
            } catch {
                logger.warning("Pet database task failed: \(error)")
                return
            }

            self.pets = pets.map { pet in
                PetModel(pet: pet)
            }

            self.petsByMonsterAegisName = Dictionary(
                self.pets.map({ ($0.monster, $0) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.petDatabaseTask = petDatabaseTask

        return await petDatabaseTask.value
    }

    func pet(for monster: MonsterModel) async -> PetModel? {
        await fetchPets()

        return petsByMonsterAegisName[monster.aegisName]
    }

    func petUsages(forItemAegisName itemAegisName: String) async -> [ItemModel.PetUsage] {
        await fetchPets()

        var petUsages: [ItemModel.PetUsage] = []

        for pet in pets {
            let kinds = pet.usages(ofItemNamed: itemAegisName)
            if !kinds.isEmpty, let monster = await monster(forAegisName: pet.monster) {
                for kind in kinds {
                    let petUsage = ItemModel.PetUsage(monster: monster, kind: kind)
                    petUsages.append(petUsage)
                }
            }
        }

        return petUsages
    }

    func petItems(for pet: PetModel) async -> [MonsterModel.PetItem] {
        await fetchItems()

        var petItems: [MonsterModel.PetItem] = []

        let itemAegisNames: [(MonsterModel.PetItem.Kind, String?)] = [(.tame, pet.tameItem), (.egg, pet.eggItem), (.equip, pet.equipItem), (.food, pet.foodItem)]
        for (kind, itemAegisName) in itemAegisNames {
            if let itemAegisName, let item = itemsByAegisName[itemAegisName] {
                let petItem = MonsterModel.PetItem(kind: kind, item: item)
                petItems.append(petItem)
            }
        }

        return petItems
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

    // MARK: - Elemental Attribute Damage Adjustment Database

    func fetchElementalAttributeDamageAdjustments() async {
        if let elementalAttributeDamageAdjustmentDatabaseTask {
            return await elementalAttributeDamageAdjustmentDatabaseTask.value
        }

        let elementalAttributeDamageAdjustmentDatabaseTask = Task {
            let elementalAttributeDamageAdjustmentDatabase = ElementalAttributeDamageAdjustmentDatabase(baseURL: serverResourceBaseURL, mode: mode)

            do {
                elementalAttributeDamageAdjustments = try await elementalAttributeDamageAdjustmentDatabase.elementalAttributeDamageAdjustments()
            } catch {
                logger.warning("Elemental attribute damage adjustment database task failed: \(error)")
            }
        }

        self.elementalAttributeDamageAdjustmentDatabaseTask = elementalAttributeDamageAdjustmentDatabaseTask

        return await elementalAttributeDamageAdjustmentDatabaseTask.value
    }

    func elementalDamages(for monster: MonsterModel) async -> [MonsterModel.ElementalDamage] {
        await fetchElementalAttributeDamageAdjustments()

        guard let adjustment = elementalAttributeDamageAdjustments.first(where: { $0.level == monster.elementLevel }) else {
            return []
        }

        let attackElements: [Element] = [.neutral, .water, .earth, .fire, .wind, .poison, .holy, .dark, .ghost, .undead]
        return attackElements.map { attackElement in
            let rate = adjustment.rate(attackElement: attackElement, defenseElement: monster.element)
            return MonsterModel.ElementalDamage(attackElement: attackElement, rate: rate)
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
                return
            }

            let uniqueName = { (npcName: String) in
                npcName.range(of: "::").map({ String(npcName[$0.upperBound...]) }) ?? npcName
            }

            shopNPCsByUniqueName = Dictionary(
                scriptCommands.shopNPCs.map({ (uniqueName($0.npcName), $0) }),
                uniquingKeysWith: { (first, _) in first }
            )

            npcCodesByUniqueName = Dictionary(
                scriptCommands.npcs.map({ (uniqueName($0.npcName), $0.code) }) + scriptCommands.floatingNPCs.map({ (uniqueName($0.npcName), $0.code) }),
                uniquingKeysWith: { (first, _) in first }
            )
        }

        self.npcDatabaseTask = npcDatabaseTask

        return await npcDatabaseTask.value
    }

    func mapFlags(forMapName mapName: String) async -> [MapFlag] {
        await fetchScriptCommands()

        var mapFlags: [MapFlag] = []

        for mapFlag in scriptCommands.mapFlags where mapFlag.mapName == mapName {
            if mapFlag.value?.lowercased() == "off" {
                mapFlags.removeAll(where: { $0.flag == mapFlag.flag })
            } else if !mapFlags.contains(where: { $0.flag == mapFlag.flag && $0.value == mapFlag.value }) {
                mapFlags.append(mapFlag)
            }
        }

        return mapFlags
    }

    func spawnMaps(for monster: (id: Int, aegisName: String)) async -> [MonsterModel.SpawnMap] {
        await fetchScriptCommands()

        var spawnMaps: [MonsterModel.SpawnMap] = []

        let monsterSpawns = scriptCommands.monsterSpawns(for: monster)
        for monsterSpawn in monsterSpawns {
            if let map = await map(forName: monsterSpawn.mapName) {
                if !spawnMaps.contains(where: { $0.map.name == map.name }) {
                    let spawnMap = MonsterModel.SpawnMap(map: map, monsterSpawn: monsterSpawn)
                    spawnMaps.append(spawnMap)
                }
            }
        }

        return spawnMaps
    }

    func spawnMonsters(forMapName mapName: String) async -> [MapModel.SpawnMonster] {
        await fetchScriptCommands()

        var spawnMonsters: [MapModel.SpawnMonster] = []
        var monsters: [MonsterModel] = []

        let monsterSpawns = scriptCommands.monsterSpawns(forMapName: mapName)
        for monsterSpawn in monsterSpawns {
            if let monsterID = monsterSpawn.monsterID {
                if let monster = await monster(forID: monsterID) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawnMonster = MapModel.SpawnMonster(monster: monster, spawn: monsterSpawn)
                        spawnMonsters.append(spawnMonster)
                    }
                }
            } else if let monsterAegisName = monsterSpawn.monsterAegisName {
                if let monster = await monster(forAegisName: monsterAegisName) {
                    if !monsters.contains(monster) {
                        monsters.append(monster)

                        let spawnMonster = MapModel.SpawnMonster(monster: monster, spawn: monsterSpawn)
                        spawnMonsters.append(spawnMonster)
                    }
                }
            }
        }

        return spawnMonsters
    }

    func warpMaps(forMapName mapName: String) async -> [MapModel] {
        await fetchScriptCommands()

        var maps: [MapModel] = []

        for warpPoint in scriptCommands.warpPoints where warpPoint.fromMapName == mapName && warpPoint.toMapName != mapName {
            if !maps.contains(where: { $0.name == warpPoint.toMapName }), let map = await map(forName: warpPoint.toMapName) {
                maps.append(map)
            }
        }

        return maps
    }

    func npcs(for map: MapModel) async -> [NPCModel] {
        await fetchScriptCommands()

        var npcs: [NPCModel] = []

        for npc in scriptCommands.npcs where npc.mapName == map.name && npc.state == nil {
            if let npc = await npcModel(for: npc, map: map) {
                npcs.append(npc)
            }
        }

        for duplicate in scriptCommands.duplicates where duplicate.mapName == map.name {
            if let npc = await npcModel(for: duplicate, map: map) {
                npcs.append(npc)
            }
        }

        for shopNPC in scriptCommands.shopNPCs where shopNPC.mapName == map.name {
            if let npc = await npcModel(for: shopNPC, map: map) {
                npcs.append(npc)
            }
        }

        let hiddenJobIDs: Set<Int> = [
            NPCJobID.jt_fakenpc.rawValue,
            NPCJobID.jt_hidden_npc.rawValue,
            NPCJobID.jt_hidden_warp_npc.rawValue,
            NPCJobID.jt_guild_flag.rawValue,
            NPCJobID.jt_invisible.rawValue,
        ]

        return npcs
            .filter {
                !hiddenJobIDs.contains($0.jobID) && !$0.displayName.isEmpty
            }
            .sorted {
                $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
            }
    }

    private func npcModel(for npc: NPC, map: MapModel) async -> NPCModel? {
        guard let x = npc.x, let y = npc.y else {
            return nil
        }

        let jobID = await jobID(forSprite: npc.sprite)
        let npcModel = NPCModel(npcName: npc.npcName, map: map, x: x, y: y, jobID: jobID, code: npc.code, resourceManager: resourceManager)
        return npcModel
    }

    private func npcModel(for duplicate: Duplicate, map: MapModel) async -> NPCModel? {
        guard let x = duplicate.x, let y = duplicate.y, let sprite = duplicate.sprite else {
            return nil
        }

        let jobID = await jobID(forSprite: sprite)
        let code = npcCodesByUniqueName[duplicate.label]
        let shopNPC = shopNPCsByUniqueName[duplicate.label]
        let npcModel = NPCModel(npcName: duplicate.npcName, map: map, x: x, y: y, jobID: jobID, code: code, shopNPC: shopNPC, resourceManager: resourceManager)
        return npcModel
    }

    private func npcModel(for shopNPC: ShopNPC, map: MapModel) async -> NPCModel? {
        guard let x = shopNPC.x, let y = shopNPC.y else {
            return nil
        }

        let jobID = await jobID(forSprite: shopNPC.sprite)
        let npcModel = NPCModel(npcName: shopNPC.npcName, map: map, x: x, y: y, jobID: jobID, shopNPC: shopNPC, resourceManager: resourceManager)
        return npcModel
    }

    private func jobID(forSprite sprite: String) async -> Int {
        if let jobID = Int(sprite) {
            return jobID
        }

        if let jobID = NPCJobID(stringValue: sprite) {
            return jobID.rawValue
        }

        if let monster = await monster(forAegisName: sprite) {
            return monster.id
        }

        return NPCJobID.jt_invisible.rawValue
    }

    func shopNPCs(for item: ItemModel) async -> [NPCModel] {
        await fetchScriptCommands()

        var shopNPCs: [NPCModel] = []

        for shopNPC in scriptCommands.shopNPCs(forItemID: item.id) {
            if let mapName = shopNPC.mapName, let map = await map(forName: mapName), let shopNPCModel = await npcModel(for: shopNPC, map: map) {
                shopNPCs.append(shopNPCModel)
            }
        }

        for duplicate in scriptCommands.duplicates {
            guard let shopNPC = shopNPCsByUniqueName[duplicate.label], shopNPC.items.contains(where: { $0.itemID == item.id }) else {
                continue
            }
            if let mapName = duplicate.mapName, let map = await map(forName: mapName), let shopNPCModel = await npcModel(for: duplicate, map: map) {
                shopNPCs.append(shopNPCModel)
            }
        }

        return shopNPCs
    }

    func shopItems(for shopNPC: ShopNPC) async -> [NPCModel.ShopItem] {
        await fetchItems()

        var shopItems: [NPCModel.ShopItem] = []

        for (index, shopNPCItem) in shopNPC.items.enumerated() {
            if let item = itemsByID[shopNPCItem.itemID] {
                let price = price(of: shopNPCItem, item: item, shopType: shopNPC.shopType)
                let shopItem = NPCModel.ShopItem(index: index, item: item, price: price, stock: shopNPCItem.stock, shopType: shopNPC.shopType)
                shopItems.append(shopItem)
            }
        }

        return shopItems
    }

    /// A negative price means the buy price of the item in a shop or marketshop, and 0 in other shops.
    private func price(of shopNPCItem: ShopNPC.Item, item: ItemModel, shopType: ShopNPC.ShopType) -> Int {
        guard shopNPCItem.price < 0 else {
            return shopNPCItem.price
        }

        switch shopType {
        case .shop, .marketshop:
            return item.buy
        case .cashshop, .itemshop, .pointshop:
            return 0
        }
    }
}
