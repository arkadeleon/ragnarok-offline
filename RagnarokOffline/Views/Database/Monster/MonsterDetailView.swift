//
//  MonsterDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MonsterDetailView: View {
    let database: Database
    let monster: Monster

    typealias DropItem = (index: Int, drop: Monster.Drop, item: Item)

    @State private var mvpDropItems: [DropItem] = []
    @State private var dropItems: [DropItem] = []

    var body: some View {
        List {
            DatabaseRecordImage {
                await ClientResourceManager.shared.animatedMonsterImage(monster.id)
            }
            .frame(width: 150, height: 150)

            Section("Info") {
                LabeledContent("ID", value: "#\(monster.id)")
                LabeledContent("Aegis Name", value: monster.aegisName)
                LabeledContent("Name", value: monster.name)

                LabeledContent("Level", value: "\(monster.level)")
                LabeledContent("HP", value: "\(monster.hp)")
                LabeledContent("SP", value: "\(monster.sp)")

                LabeledContent("Base Exp", value: "\(monster.baseExp)")
                LabeledContent("Job Exp", value: "\(monster.jobExp)")
                LabeledContent("MVP Exp", value: "\(monster.mvpExp)")

                if database.mode == .prerenewal {
                    LabeledContent("Minimum Attack", value: "\(monster.attack)")
                    LabeledContent("Maximum Attack", value: "\(monster.attack2)")
                }

                if database.mode == .renewal {
                    LabeledContent("Base Attack", value: "\(monster.attack)")
                    LabeledContent("Base Magic Attack", value: "\(monster.attack2)")
                }

                LabeledContent("Defense", value: "\(monster.defense)")
                LabeledContent("Magic Defense", value: "\(monster.magicDefense)")

                LabeledContent("Resistance", value: "\(monster.resistance)")
                LabeledContent("Magic Resistance", value: "\(monster.magicResistance)")

                LabeledContent("Str", value: "\(monster.str)")
                LabeledContent("Agi", value: "\(monster.agi)")
                LabeledContent("Vit", value: "\(monster.vit)")
                LabeledContent("Int", value: "\(monster.int)")
                LabeledContent("Dex", value: "\(monster.dex)")
                LabeledContent("Luk", value: "\(monster.luk)")

                LabeledContent("Attack Range", value: "\(monster.attackRange)")
                LabeledContent("Skill Cast Range", value: "\(monster.skillRange)")
                LabeledContent("Chase Range", value: "\(monster.chaseRange)")

                LabeledContent("Size", value: monster.size.description)
                LabeledContent("Race", value: monster.race.description)

                LabeledContent("Element", value: monster.element.description)
                LabeledContent("Element Level", value: "\(monster.elementLevel)")

                LabeledContent("Walk Speed", value: "\(monster.walkSpeed.rawValue)")
                LabeledContent("Attack Speed", value: "\(monster.attackDelay)")
                LabeledContent("Attack Animation Speed", value: "\(monster.attackMotion)")
                LabeledContent("Damage Animation Speed", value: "\(monster.damageMotion)")
                LabeledContent("Damage Taken", value: "\(monster.damageTaken)")

                LabeledContent("AI", value: monster.ai.description)
                LabeledContent("Class", value: monster.class.description)
            }

            if let raceGroups = monster.raceGroups {
                Section("Race Groups") {
                    Text(raceGroups.map({ "- \($0.description)" }).joined(separator: "\n"))
                }
            }

            if let modes = monster.modes {
                Section("Modes") {
                    Text(modes.map({ "- \($0.description)" }).joined(separator: "\n"))
                }
            }

            if !mvpDropItems.isEmpty {
                Section("MVP Drops") {
                    ForEach(mvpDropItems, id: \.index) { dropItem in
                        NavigationLink {
                            ItemDetailView(database: database, item: dropItem.item)
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
                            ItemDetailView(database: database, item: dropItem.item)
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
