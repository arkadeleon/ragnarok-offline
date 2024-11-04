//
//  ItemInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI
import ROClientResources
import RODatabase
import ROGenerated
import ROLocalizations

struct ItemInfoView: View {
    var mode: DatabaseMode
    var item: Item

    typealias DroppingMonster = (monster: ObservableMonster, drop: Monster.Drop)

    @State private var itemPreviewImage: CGImage?
    @State private var localizedItemDescription: String?
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
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
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

            if let localizedItemDescription {
                DatabaseRecordInfoSection("Description") {
                    Text(localizedItemDescription)
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
                                MonsterGridCell(monster: droppingMonster.monster, secondaryText: "(" + (Double(droppingMonster.drop.rate) / 100).formatted() + "%)")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
        }
        .background(.background)
        .navigationTitle(title)
        .task {
            await loadItemInfo()
        }
    }

    private var title: String {
        item.slots > 0 ? item.name + " [\(item.slots)]" : item.name
    }

    private var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: "ID", value: "#\(item.id)"))
        attributes.append(.init(name: "Aegis Name", value: item.aegisName))
        attributes.append(.init(name: "Name", value: item.name))
        attributes.append(.init(name: "Type", value: item.type.localizedStringResource))

        switch item.subType {
        case .none:
            break
        case .weapon(let weaponType):
            attributes.append(.init(name: "Weapon Type", value: weaponType.localizedStringResource))
        case .ammo(let ammoType):
            attributes.append(.init(name: "Ammo Type", value: ammoType.stringValue))
        case .card(let cardType):
            attributes.append(.init(name: "Card Type", value: cardType.stringValue))
        }

        attributes.append(.init(name: "Buy", value: item.buy.formatted() + "z"))
        attributes.append(.init(name: "Sell", value: item.sell.formatted() + "z"))
        attributes.append(.init(name: "Weight", value: Double(item.weight) / 10))

        switch item.type {
        case .weapon:
            attributes.append(.init(name: "Attack", value: item.attack))
            attributes.append(.init(name: "Magic Attack", value: item.magicAttack))
            attributes.append(.init(name: "Attack Range", value: item.range))
            attributes.append(.init(name: "Slots", value: item.slots))
        case .armor:
            attributes.append(.init(name: "Defense", value: item.defense))
            attributes.append(.init(name: "Slots", value: item.slots))
        default:
            break
        }

        switch item.type {
        case .weapon, .armor:
            attributes.append(.init(name: "Gender", value: item.gender.stringValue))
        default:
            break
        }

        switch item.type {
        case .weapon:
            attributes.append(.init(name: "Weapon Level", value: item.weaponLevel))
        case .armor:
            attributes.append(.init(name: "Armor Level", value: item.armorLevel))
        default:
            break
        }

        switch item.type {
        case .weapon, .armor:
            attributes.append(.init(name: "Minimum Level", value: item.equipLevelMin))
            attributes.append(.init(name: "Maximum Level", value: item.equipLevelMax))
            attributes.append(.init(name: "Refinable", value: item.refineable))
            attributes.append(.init(name: "Gradable", value: item.gradable))
            attributes.append(.init(name: "View", value: item.view))
        default:
            break;
        }

        return attributes
    }

    private var jobs: String {
        item.jobs
            .sorted(using: KeyPathComparator(\.intValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
    }

    private var classes: String {
        OptionSetSequence(item.classes)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
    }

    private var locations: String {
        OptionSetSequence(item.locations)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- \($0.stringValue)" }
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
        localizedItemDescription = ItemInfoTable.shared.localizedIdentifiedItemDescription(forItemID: item.id)
        itemPreviewImage = await ClientResourceManager.default.itemPreviewImage(forItemID: item.id)

        let monsterDatabase = MonsterDatabase.database(for: mode)

        if let monsters = try? await monsterDatabase.monsters() {
            var droppingMonsters: [DroppingMonster] = []
            for monster in monsters {
                let drops = (monster.mvpDrops ?? []) + (monster.drops ?? [])
                for drop in drops {
                    if drop.item == item.aegisName {
                        let observableMonster = ObservableMonster(mode: mode, monster: monster)
                        droppingMonsters.append((observableMonster, drop))
                        break
                    }
                }
            }
            self.droppingMonsters = droppingMonsters
        }
    }
}
