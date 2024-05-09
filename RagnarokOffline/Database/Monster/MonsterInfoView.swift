//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import RODatabase
import ROResources

struct MonsterInfoView: View {
    let database: Database
    let monster: Monster

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
                    ForEach(fields, id: \.title) { field in
                        LabeledContent(field.title, value: field.value)
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
                                ItemGridCell(item: dropItem.item, secondaryText: "(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
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
                                ItemGridCell(item: dropItem.item, secondaryText: "(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
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
                                MapGridCell(map: spawnMap.map, secondaryText: "(\(spawnMap.monsterSpawn.amount)x)")
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

    private var fields: [DatabaseRecordField] {
        var fields: [DatabaseRecordField] = []

        fields.append(("ID", "#\(monster.id)"))
        fields.append(("Aegis Name", monster.aegisName))
        fields.append(("Name", monster.name))

        fields.append(("Level", "\(monster.level)"))
        fields.append(("HP", "\(monster.hp)"))
        fields.append(("SP", "\(monster.sp)"))

        fields.append(("Base Exp", "\(monster.baseExp)"))
        fields.append(("Job Exp", "\(monster.jobExp)"))
        fields.append(("MVP Exp", "\(monster.mvpExp)"))

        if database.mode == .prerenewal {
            fields.append(("Minimum Attack", "\(monster.attack)"))
            fields.append(("Maximum Attack", "\(monster.attack2)"))
        }

        if database.mode == .renewal {
            fields.append(("Base Attack", "\(monster.attack)"))
            fields.append(("Base Magic Attack", "\(monster.attack2)"))
        }

        fields.append(("Defense", "\(monster.defense)"))
        fields.append(("Magic Defense", "\(monster.magicDefense)"))

        fields.append(("Resistance", "\(monster.resistance)"))
        fields.append(("Magic Resistance", "\(monster.magicResistance)"))

        fields.append(("Str", "\(monster.str)"))
        fields.append(("Agi", "\(monster.agi)"))
        fields.append(("Vit", "\(monster.vit)"))
        fields.append(("Int", "\(monster.int)"))
        fields.append(("Dex", "\(monster.dex)"))
        fields.append(("Luk", "\(monster.luk)"))

        fields.append(("Attack Range", "\(monster.attackRange)"))
        fields.append(("Skill Cast Range", "\(monster.skillRange)"))
        fields.append(("Chase Range", "\(monster.chaseRange)"))

        fields.append(("Size", monster.size.description))
        fields.append(("Race", monster.race.description))

        fields.append(("Element", monster.element.description))
        fields.append(("Element Level", "\(monster.elementLevel)"))

        fields.append(("Walk Speed", "\(monster.walkSpeed.rawValue)"))
        fields.append(("Attack Speed", "\(monster.attackDelay)"))
        fields.append(("Attack Animation Speed", "\(monster.attackMotion)"))
        fields.append(("Damage Animation Speed", "\(monster.damageMotion)"))
        fields.append(("Damage Taken", "\(monster.damageTaken)"))

        fields.append(("AI", monster.ai.description))
        fields.append(("Class", monster.class.description))

        return fields
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

        let itemDatabase = ItemDatabase.database(for: database.mode)

        do {
            if let mvpDrops = monster.mvpDrops {
                var mvpDropItems: [DropItem] = []
                for (index, drop) in mvpDrops.enumerated() {
                    let item = try await itemDatabase.item(forAegisName: drop.item)
                    mvpDropItems.append((index, drop, item))
                }
                self.mvpDropItems = mvpDropItems
            }
        } catch {
        }

        do {
            if let drops = monster.drops {
                var dropItems: [DropItem] = []
                for (index, drop) in drops.enumerated() {
                    let item = try await itemDatabase.item(forAegisName: drop.item)
                    dropItems.append((index, drop, item))
                }
                self.dropItems = dropItems
            }
        } catch {
        }

        do {
            var spawnMaps: [SpawnMap] = []
            let monsterSpawns = try await database.monsterSpawns(forMonster: monster)
            for monsterSpawn in monsterSpawns {
                let map = try await database.map(forName: monsterSpawn.mapName)
                if !spawnMaps.contains(where: { $0.map == map }) {
                    spawnMaps.append((map, monsterSpawn))
                }
            }
            self.spawnMaps = spawnMaps
        } catch {
        }
    }
}
