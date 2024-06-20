//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import rAthenaCommon
import ROClient
import RODatabase

struct MonsterInfoView: View {
    var mode: ServerMode
    var monster: Monster

    typealias DropItem = (index: Int, drop: Monster.Drop, item: Item)
    typealias SpawnMap = (map: Map, monsterSpawn: MonsterSpawn)

    @State private var monsterImage: CGImage?
    @State private var mvpDropItems: [DropItem] = []
    @State private var dropItems: [DropItem] = []
    @State private var spawnMaps: [SpawnMap] = []

    var body: some View {
        ScrollView {
            ZStack {
                if let monsterImage {
                    if monsterImage.height > 200 {
                        Image(monsterImage, scale: 1, label: Text(monster.name))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(monsterImage, scale: 1, label: Text(monster.name))
                    }
                } else {
                    Image(systemName: "pawprint")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 100))
                }
            }
            .frame(height: 200)

            DatabaseRecordInfoSection("Info") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], spacing: 10) {
                    ForEach(attributes) { attribute in
                        LabeledContent {
                            Text(attribute.value)
                        } label: {
                            Text(attribute.name)
                        }
                    }
                }
            }

            if let raceGroups {
                DatabaseRecordInfoSection("Race Groups") {
                    Text(raceGroups)
                }
            }

            if let modes {
                DatabaseRecordInfoSection("Modes") {
                    Text(modes)
                }
            }

            if !mvpDropItems.isEmpty {
                DatabaseRecordInfoSection("MVP Drops", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(mvpDropItems, id: \.index) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            if !dropItems.isEmpty {
                DatabaseRecordInfoSection("Drops", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(dropItems, id: \.index) { dropItem in
                            NavigationLink(value: dropItem.item) {
                                ItemCell(item: dropItem.item, secondaryText: "(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }

            if !spawnMaps.isEmpty {
                DatabaseRecordInfoSection("Maps", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(spawnMaps, id: \.map.index) { spawnMap in
                            NavigationLink(value: spawnMap.map) {
                                MapCell(map: spawnMap.map, secondaryText: "(\(spawnMap.monsterSpawn.amount)x)")
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle(monster.name)
        .task {
            await loadMonsterInfo()
        }
    }

    private var attributes: [DatabaseRecordAttribute] {
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

        attributes.append(.init(name: "Size", value: monster.size.description))
        attributes.append(.init(name: "Race", value: monster.race.description))

        attributes.append(.init(name: "Element", value: monster.element.description))
        attributes.append(.init(name: "Element Level", value: monster.elementLevel))

        attributes.append(.init(name: "Walk Speed", value: monster.walkSpeed.rawValue))
        attributes.append(.init(name: "Attack Delay", value: monster.attackDelay))
        attributes.append(.init(name: "Attack Motion", value: monster.attackMotion))
        attributes.append(.init(name: "Client Attack Motion", value: monster.clientAttackMotion))
        attributes.append(.init(name: "Damage Motion", value: monster.damageMotion))
        attributes.append(.init(name: "Damage Taken", value: monster.damageTaken))

        attributes.append(.init(name: "AI", value: monster.ai.description))
        attributes.append(.init(name: "Class", value: monster.class.description))

        return attributes
    }

    private var raceGroups: String? {
        monster.raceGroups?
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    private var modes: String? {
        monster.modes?
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    private func loadMonsterInfo() async {
        monsterImage = await ClientResourceManager.shared.monsterImage(monster.id)

        let itemDatabase = ItemDatabase.database(for: mode)
        let mapDatabase = MapDatabase.database(for: mode)
        let npcDatabase = NPCDatabase.database(for: mode)

        if let mvpDrops = monster.mvpDrops {
            var mvpDropItems: [DropItem] = []
            for (index, drop) in mvpDrops.enumerated() {
                if let item = try? await itemDatabase.item(forAegisName: drop.item) {
                    mvpDropItems.append((index, drop, item))
                }
            }
            self.mvpDropItems = mvpDropItems
        }

        if let drops = monster.drops {
            var dropItems: [DropItem] = []
            for (index, drop) in drops.enumerated() {
                if let item = try? await itemDatabase.item(forAegisName: drop.item) {
                    dropItems.append((index, drop, item))
                }
            }
            self.dropItems = dropItems
        }

        if let monsterSpawns = try? await npcDatabase.monsterSpawns(forMonster: monster) {
            var spawnMaps: [SpawnMap] = []
            for monsterSpawn in monsterSpawns {
                if let map = try? await mapDatabase.map(forName: monsterSpawn.mapName) {
                    if !spawnMaps.contains(where: { $0.map == map }) {
                        spawnMaps.append((map, monsterSpawn))
                    }
                }
            }
            self.spawnMaps = spawnMaps
        }
    }
}
