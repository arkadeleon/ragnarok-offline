//
//  ObservableItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/6.
//

import CoreGraphics
import Foundation
import Observation
import ROClientResources
import RODatabase
import ROLocalizations

@Observable
@dynamicMemberLookup
class ObservableItem {
    struct DroppingMonster: Identifiable {
        var monster: ObservableMonster
        var drop: Monster.Drop

        var id: Int {
            monster.id
        }
    }

    private let mode: DatabaseMode
    private let item: Item

    var localizedName: String?
    var iconImage: CGImage?
    var previewImage: CGImage?
    var localizedDescription: String?
    var droppingMonsters: [DroppingMonster] = []

    var displayName: String {
        var displayName = localizedName ?? item.name
        if item.slots > 0 {
            displayName += " [\(item.slots)]"
        }
        return displayName
    }

    var attributes: [DatabaseRecordAttribute] {
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

    var jobs: String {
        item.jobs
            .sorted(using: KeyPathComparator(\.intValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
    }

    var classes: String {
        OptionSetSequence(item.classes)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
    }

    var locations: String {
        OptionSetSequence(item.locations)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
    }

    init(mode: DatabaseMode, item: Item) {
        self.mode = mode
        self.item = item
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Item, Value>) -> Value {
        item[keyPath: keyPath]
    }

    func fetchLocalizedName() {
        localizedName = ItemInfoTable.shared.localizedIdentifiedItemName(forItemID: item.id)
    }

    func fetchIconImage() async {
        if iconImage == nil {
            iconImage = await ClientResourceManager.default.itemIconImage(forItemID: item.id)
        }
    }

    func fetchDetail() async {
        previewImage = await ClientResourceManager.default.itemPreviewImage(forItemID: item.id)

        localizedDescription = ItemInfoTable.shared.localizedIdentifiedItemDescription(forItemID: item.id)

        let monsterDatabase = MonsterDatabase.database(for: mode)

        if let monsters = try? await monsterDatabase.monsters() {
            var droppingMonsters: [DroppingMonster] = []
            for monster in monsters {
                let drops = (monster.mvpDrops ?? []) + (monster.drops ?? [])
                for drop in drops {
                    if drop.item == item.aegisName {
                        let droppingMonster = DroppingMonster(
                            monster: ObservableMonster(mode: mode, monster: monster),
                            drop: drop
                        )
                        droppingMonsters.append(droppingMonster)
                        break
                    }
                }
            }
            self.droppingMonsters = droppingMonsters
        }
    }
}

extension ObservableItem: Hashable {
    static func == (lhs: ObservableItem, rhs: ObservableItem) -> Bool {
        lhs.item.id == rhs.item.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
    }
}

extension ObservableItem: Identifiable {
    var id: Int {
        item.id
    }
}