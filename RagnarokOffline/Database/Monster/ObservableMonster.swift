//
//  ObservableMonster.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/19.
//

import CoreGraphics
import Observation
import rAthenaCommon
import ROClientResources
import RODatabase
import ROLocalizations

@Observable
class ObservableMonster {
    private let mode: ServerMode
    private let monster: Monster

    let localizedName: String

    var mvpDropItems: [DropItem] = []
    var dropItems: [DropItem] = []
    var spawnMaps: [SpawnMap] = []

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "ID", value: "#\(monster.id)"))
        attributes.append(.init(name: "Aegis Name", value: monster.aegisName))
        attributes.append(.init(name: "Name", value: monster.name))

        attributes.append(.init(name: "Level", value: monster.level))
        attributes.append(.init(name: "HP", value: monster.hp))
        attributes.append(.init(name: "SP", value: monster.sp))

        attributes.append(.init(name: "Base Exp", value: monster.baseExp))
        attributes.append(.init(name: "Job Exp", value: monster.jobExp))
        attributes.append(.init(name: "MVP Exp", value: monster.mvpExp))

        if mode == .prerenewal {
            attributes.append(.init(name: "Minimum Attack", value: monster.attack))
            attributes.append(.init(name: "Maximum Attack", value: monster.attack2))
        }

        if mode == .renewal {
            attributes.append(.init(name: "Base Attack", value: monster.attack))
            attributes.append(.init(name: "Base Magic Attack", value: monster.attack2))
        }

        attributes.append(.init(name: "Defense", value: monster.defense))
        attributes.append(.init(name: "Magic Defense", value: monster.magicDefense))

        attributes.append(.init(name: "Resistance", value: monster.resistance))
        attributes.append(.init(name: "Magic Resistance", value: monster.magicResistance))

        attributes.append(.init(name: "Str", value: monster.str))
        attributes.append(.init(name: "Agi", value: monster.agi))
        attributes.append(.init(name: "Vit", value: monster.vit))
        attributes.append(.init(name: "Int", value: monster.int))
        attributes.append(.init(name: "Dex", value: monster.dex))
        attributes.append(.init(name: "Luk", value: monster.luk))

        attributes.append(.init(name: "Attack Range", value: monster.attackRange))
        attributes.append(.init(name: "Skill Range", value: monster.skillRange))
        attributes.append(.init(name: "Chase Range", value: monster.chaseRange))

        attributes.append(.init(name: "Size", value: monster.size.stringValue))
        attributes.append(.init(name: "Race", value: monster.race.localizedStringResource))

        attributes.append(.init(name: "Element", value: monster.element.stringValue))
        attributes.append(.init(name: "Element Level", value: monster.elementLevel))

        attributes.append(.init(name: "Walk Speed", value: monster.walkSpeed.rawValue))
        attributes.append(.init(name: "Attack Delay", value: monster.attackDelay))
        attributes.append(.init(name: "Attack Motion", value: monster.attackMotion))
        attributes.append(.init(name: "Client Attack Motion", value: monster.clientAttackMotion))
        attributes.append(.init(name: "Damage Motion", value: monster.damageMotion))
        attributes.append(.init(name: "Damage Taken", value: monster.damageTaken))

        attributes.append(.init(name: "AI", value: monster.ai.stringValue))
        attributes.append(.init(name: "Class", value: monster.class.stringValue))

        return attributes
    }

    var raceGroups: String? {
        monster.raceGroups?
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- " + $0.stringValue }
            .joined(separator: "\n")
    }

    var modes: String? {
        monster.modes?
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- " + $0.stringValue }
            .joined(separator: "\n")
    }

    init(mode: ServerMode, monster: Monster) {
        self.mode = mode
        self.monster = monster

        let localizedName = MonsterInfoTable.shared.localizedMonsterName(forMonsterID: monster.id)
        self.localizedName = localizedName ?? monster.name
    }

    func fetchImage() async -> CGImage? {
        await ClientResourceManager.default.monsterImage(monster.id)
    }

    func fetchDetail() async throws {
        let itemDatabase = ItemDatabase.database(for: mode)
        let mapDatabase = MapDatabase.database(for: mode)
        let npcDatabase = NPCDatabase.database(for: mode)

        if let mvpDrops = monster.mvpDrops {
            var mvpDropItems: [DropItem] = []
            for (index, drop) in mvpDrops.enumerated() {
                if let item = try await itemDatabase.item(forAegisName: drop.item) {
                    mvpDropItems.append((index, drop, item))
                }
            }
            self.mvpDropItems = mvpDropItems
        }

        if let drops = monster.drops {
            var dropItems: [DropItem] = []
            for (index, drop) in drops.enumerated() {
                if let item = try await itemDatabase.item(forAegisName: drop.item) {
                    dropItems.append((index, drop, item))
                }
            }
            self.dropItems = dropItems
        }

        let monsterSpawns = try await npcDatabase.monsterSpawns(forMonster: monster)
        var spawnMaps: [SpawnMap] = []
        for monsterSpawn in monsterSpawns {
            if let map = try await mapDatabase.map(forName: monsterSpawn.mapName) {
                if !spawnMaps.contains(where: { $0.map == map }) {
                    spawnMaps.append((map, monsterSpawn))
                }
            }
        }
        self.spawnMaps = spawnMaps
    }
}

extension ObservableMonster {
    typealias DropItem = (index: Int, drop: Monster.Drop, item: Item)
    typealias SpawnMap = (map: Map, monsterSpawn: MonsterSpawn)
}

extension ObservableMonster: Equatable {
    static func == (lhs: ObservableMonster, rhs: ObservableMonster) -> Bool {
        lhs.monster == rhs.monster
    }
}

extension ObservableMonster: Hashable {
    func hash(into hasher: inout Hasher) {
        monster.hash(into: &hasher)
    }
}

extension ObservableMonster: Identifiable {
    var id: Int {
        monster.id
    }
}
