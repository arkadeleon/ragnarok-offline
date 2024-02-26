//
//  ItemDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct ItemDetailView: View {
    let database: Database
    let item: Item

    typealias DroppingMonster = (monster: Monster, drop: Monster.Drop)

    @State private var itemPreview: UIImage?
    @State private var itemDescription: String?
    @State private var droppingMonsters: [DroppingMonster] = []

    var fields: [DatabaseRecordField] {
        var fields: [DatabaseRecordField] = []

        fields.append(("ID", "#\(item.id)"))
        fields.append(("Aegis Name", item.aegisName))
        fields.append(("Name", item.name))
        fields.append(("Type", item.type.description))

        switch item.subType {
        case .none:
            break
        case .weapon(let weaponType):
            fields.append(("Weapon Type", weaponType.description))
        case .ammo(let ammoType):
            fields.append(("Ammo Type", ammoType.description))
        case .card(let cardType):
            fields.append(("Card Type", cardType.description))
        }

        fields.append(("Buy", "\(item.buy)z"))
        fields.append(("Sell", "\(item.sell)z"))
        fields.append(("Weight", "\(item.weight / 10)"))

        switch item.type {
        case .weapon:
            fields.append(("Attack", "\(item.attack)"))
            fields.append(("Magic Attack", "\(item.magicAttack)"))
            fields.append(("Attack Range", "\(item.range)"))
            fields.append(("Slots", "\(item.slots)"))
        case .armor:
            fields.append(("Defense", "\(item.defense)"))
            fields.append(("Slots", "\(item.slots)"))
        default:
            break
        }

        fields.append(("Gender", item.gender.description))

        switch item.type {
        case .weapon:
            fields.append(("Weapon Level", "\(item.weaponLevel)"))
        case .armor:
            fields.append(("Armor Level", "\(item.armorLevel)"))
        default:
            break
        }

        switch item.type {
        case .weapon, .armor:
            fields.append(("Minimum Level", "\(item.equipLevelMin)"))
            fields.append(("Maximum Level", "\(item.equipLevelMax)"))
            fields.append(("Refinable", item.refineable ? "Yes" : "No"))
            fields.append(("Gradable", item.gradable ? "Yes" : "No"))
            fields.append(("View", "\(item.view)"))
        default:
            break;
        }

        return fields
    }

    var jobs: String {
        item.jobs
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    var classes: String {
        item.classes
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    var locations: String {
        item.locations
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    var script: String? {
        item.script?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var equipScript: String? {
        item.equipScript?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var unEquipScript: String? {
        item.unEquipScript?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        List {
            VStack(alignment: .center) {
                if let itemPreview {
                    Image(uiImage: itemPreview)
                } else {
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150, alignment: .center)

            Section("Info") {
                ForEach(fields, id: \.title) { field in
                    LabeledContent(field.title, value: field.value)
                }
            }

            if item.type == .weapon || item.type == .armor {
                Section("Jobs") {
                    Text(jobs)
                }

                Section("Classes") {
                    Text(classes)
                }

                Section("Locations") {
                    Text(locations)
                }
            }

            if let itemDescription {
                Section("Description") {
                    Text(itemDescription)
                }
            }

            if let script {
                Section("Script") {
                    Text(script)
                        .monospaced()
                }
            }

            if let equipScript {
                Section("Equip Script") {
                    Text(equipScript)
                        .monospaced()
                }
            }

            if let unEquipScript {
                Section("Unequip Script") {
                    Text(unEquipScript)
                        .monospaced()
                }
            }

            if !droppingMonsters.isEmpty {
                Section("Dropping Monsters") {
                    ForEach(droppingMonsters, id: \.monster.id) { droppingMonster in
                        NavigationLink {
                            MonsterDetailView(database: database, monster: droppingMonster.monster)
                        } label: {
                            HStack {
                                Text(droppingMonster.monster.name)

                                Text("(\(NSNumber(value: Double(droppingMonster.drop.rate) / 100))%)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            Task {
                itemPreview = await ClientResourceManager.shared.itemPreviewImage(item.id)
                itemDescription = ClientDatabase.shared.itemDescription(item.id)

                var droppingMonsters: [DroppingMonster] = []
                let monsters = try await database.monsters().joined()
                for monster in monsters {
                    let drops = (monster.mvpDrops ?? []) + (monster.drops ?? [])
                    for drop in drops {
                        if drop.item == item.aegisName {
                            droppingMonsters.append((monster, drop))
                            break
                        }
                    }
                }
                self.droppingMonsters = droppingMonsters
            }
        }
    }
}
