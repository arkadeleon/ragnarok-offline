//
//  MonsterInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MonsterInfoView: View {
    let database: Database
    let monster: Monster

    typealias DropItem = (index: Int, drop: Monster.Drop, item: Item)

    @State private var mvpDropItems: [DropItem] = []
    @State private var dropItems: [DropItem] = []

    var fields: [DatabaseRecordField] {
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

    var raceGroups: String? {
        monster.raceGroups?
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    var modes: String? {
        monster.modes?
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    var body: some View {
        List {
            DatabaseRecordImage {
                await ClientResourceManager.shared.animatedMonsterImage(monster.id)
            }
            .frame(width: 150, height: 150)

            Section("Info") {
                ForEach(fields, id: \.title) { field in
                    LabeledContent(field.title, value: field.value)
                }
            }

            if let raceGroups {
                Section("Race Groups") {
                    Text(raceGroups)
                }
            }

            if let modes {
                Section("Modes") {
                    Text(modes)
                }
            }

            if !mvpDropItems.isEmpty {
                Section("MVP Drops") {
                    ForEach(mvpDropItems, id: \.index) { dropItem in
                        NavigationLink {
                            ItemInfoView(database: database, item: dropItem.item)
                        } label: {
                            HStack {
                                DatabaseRecordImage {
                                    await ClientResourceManager.shared.itemIconImage(dropItem.item.id)
                                }
                                .frame(width: 24, height: 24)

                                Text(dropItem.item.name)

                                Text("(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            if !dropItems.isEmpty {
                Section("Drops") {
                    ForEach(dropItems, id: \.index) { dropItem in
                        NavigationLink {
                            ItemInfoView(database: database, item: dropItem.item)
                        } label: {
                            HStack {
                                DatabaseRecordImage {
                                    await ClientResourceManager.shared.itemIconImage(dropItem.item.id)
                                }
                                .frame(width: 24, height: 24)

                                Text(dropItem.item.name)

                                Text("(\(NSNumber(value: Double(dropItem.drop.rate) / 100))%)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(monster.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                if let mvpDrops = monster.mvpDrops {
                    var mvpDropItems: [DropItem] = []
                    for (index, drop) in mvpDrops.enumerated() {
                        let item = try await database.item(for: drop.item)
                        mvpDropItems.append((index, drop, item))
                    }
                    self.mvpDropItems = mvpDropItems
                }

                if let drops = monster.drops {
                    var dropItems: [DropItem] = []
                    for (index, drop) in drops.enumerated() {
                        let item = try await database.item(for: drop.item)
                        dropItems.append((index, drop, item))
                    }
                    self.dropItems = dropItems
                }
            }
        }
    }
}
