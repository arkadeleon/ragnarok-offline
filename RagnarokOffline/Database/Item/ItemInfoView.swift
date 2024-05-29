//
//  ItemInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import rAthenaCommon
import ROClient
import RODatabase
import ROResources

struct ItemInfoView: View {
    let mode: ServerMode
    let item: Item

    typealias DroppingMonster = (monster: Monster, drop: Monster.Drop)

    @State private var itemPreviewImage: CGImage?
    @State private var itemDescription: String?
    @State private var droppingMonsters: [DroppingMonster] = []

    var body: some View {
        ScrollView {
            ZStack {
                if let itemPreviewImage {
                    Image(itemPreviewImage, scale: 1, label: Text(item.name))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "leaf")
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

            if item.type == .weapon || item.type == .armor {
                DatabaseRecordInfoSection("Jobs") {
                    Text(jobs)
                }

                DatabaseRecordInfoSection("Classes") {
                    Text(classes)
                }

                DatabaseRecordInfoSection("Locations") {
                    Text(locations)
                }
            }

            if let itemDescription {
                DatabaseRecordInfoSection("Description") {
                    Text(itemDescription)
                }
            }

            if let script {
                DatabaseRecordInfoSection("Script") {
                    Text(script)
                        .monospaced()
                }
            }

            if let equipScript {
                DatabaseRecordInfoSection("Equip Script") {
                    Text(equipScript)
                        .monospaced()
                }
            }

            if let unEquipScript {
                DatabaseRecordInfoSection("Unequip Script") {
                    Text(unEquipScript)
                        .monospaced()
                }
            }

            if !droppingMonsters.isEmpty {
                DatabaseRecordInfoSection("Dropping Monsters", verticalSpacing: 0) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                        ForEach(droppingMonsters, id: \.monster.id) { droppingMonster in
                            NavigationLink(value: droppingMonster.monster) {
                                MonsterGridCell(monster: droppingMonster.monster, secondaryText: "(\(NSNumber(value: Double(droppingMonster.drop.rate) / 100))%)")
                            }
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
        }
        .navigationTitle(title)
        .task {
            await loadItemInfo()
        }
    }

    private var title: String {
        item.slots > 0 ? item.name + " [\(item.slots)]" : item.name
    }

    private var fields: [DatabaseRecordField] {
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
        fields.append(("Weight", "\(NSNumber(value: Double(item.weight) / 10))"))

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

        switch item.type {
        case .weapon, .armor:
            fields.append(("Gender", item.gender.description))
        default:
            break
        }

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

    private var jobs: String {
        item.jobs
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    private var classes: String {
        item.classes
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    private var locations: String {
        item.locations
            .map({ "- \($0.description)" })
            .joined(separator: "\n")
    }

    private var script: String? {
        item.script?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var equipScript: String? {
        item.equipScript?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var unEquipScript: String? {
        item.unEquipScript?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadItemInfo() async {
        itemDescription = await ItemLocalization.shared.localizedDescription(for: item.id)
        itemPreviewImage = await ClientResourceBundle.shared.itemPreviewImage(forItem: item)

        let monsterDatabase = MonsterDatabase.database(for: mode)

        if let monsters = try? await monsterDatabase.monsters() {
            var droppingMonsters: [DroppingMonster] = []
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
