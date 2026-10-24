//
//  ItemModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/6.
//

import CoreGraphics
import Foundation
import Observation
import RagnarokConstants
import RagnarokDatabase
import RagnarokResources

@Observable
@dynamicMemberLookup
final class ItemModel {
    struct ItemCombo: Identifiable {
        var id: Int
        var items: [ItemModel]
        var script: String?
    }

    struct DropSource: Identifiable {
        var monster: MonsterModel
        var drop: Monster.Drop
        var isMVPDrop: Bool

        var id: String {
            isMVPDrop ? "\(monster.id)-mvp" : "\(monster.id)"
        }

        var badges: [DatabaseBadge] {
            var badges: [DatabaseBadge] = [.rate(drop.rate, base: 10000)]

            if isMVPDrop {
                badges.append(.mvp)
            }

            return badges
        }
    }

    struct ObtainSource: Identifiable {
        var item: ItemModel
        var itemGroup: ItemGroupModel
        var subGroupListItemChance: ItemGroupModel.SubGroupListItemChance

        var id: String {
            "\(item.id)-\(itemGroup.displayName)"
        }

        var badges: [DatabaseBadge] {
            var badges: [DatabaseBadge] = []

            if subGroupListItemChance.listItem.amount > 1 {
                badges.append(.amount(subGroupListItemChance.listItem.amount))
            }

            badges.append(.probability(subGroupListItemChance.probability))

            return badges
        }
    }

    struct PetUsage: Identifiable {
        var monster: MonsterModel
        var kind: MonsterModel.PetItem.Kind

        var id: String {
            "\(monster.id)-\(kind)"
        }

        var badges: [DatabaseBadge] {
            [.petItem(kind)]
        }
    }

    private let mode: DatabaseMode
    private let item: Item
    private let resourceManager: ResourceManager

    let localizedName: String?
    let localizedDescription: String?

    var iconImage: Resources.Image?
    var previewImage: Resources.Image?

    var displayName: String {
        var displayName = localizedName ?? item.name
        if item.slots > 0 {
            displayName += " [\(item.slots.formatted())]"
        }
        return displayName
    }

    var weaponType: WeaponType? {
        if case .weapon(let weaponType) = item.subType {
            weaponType
        } else {
            nil
        }
    }

    var ammoType: AmmoType? {
        if case .ammo(let ammoType) = item.subType {
            ammoType
        } else {
            nil
        }
    }

    var cardType: CardType? {
        if case .card(let cardType) = item.subType {
            cardType
        } else {
            nil
        }
    }

    var attributes: [DatabaseRecordAttribute] {
        var attributes: [DatabaseRecordAttribute] = []

        attributes.append(.init(name: LocalizedStringResource("ID", table: "Database"), value: String(item.id)))
        attributes.append(.init(name: LocalizedStringResource("Aegis Name", table: "Database"), value: item.aegisName))
        attributes.append(.init(name: LocalizedStringResource("Name", table: "Database"), value: item.name))
        attributes.append(.init(name: LocalizedStringResource("Type", table: "Database"), value: item.type.localizedName))

        switch item.subType {
        case .none:
            break
        case .weapon(let weaponType):
            attributes.append(.init(name: LocalizedStringResource("Weapon Type", table: "Database"), value: weaponType.localizedName))
        case .ammo(let ammoType):
            attributes.append(.init(name: LocalizedStringResource("Ammo Type", table: "Database"), value: ammoType.localizedName))
        case .card(let cardType):
            attributes.append(.init(name: LocalizedStringResource("Card Type", table: "Database"), value: cardType.localizedName))
        }

        attributes.append(.init(name: LocalizedStringResource("Buy", table: "Database"), value: formatZeny(item.buy)))
        attributes.append(.init(name: LocalizedStringResource("Sell", table: "Database"), value: formatZeny(item.sell)))
        attributes.append(.init(name: LocalizedStringResource("Weight", table: "Database"), value: formatWeight(item.weight)))

        switch item.type {
        case .weapon:
            attributes.append(.init(name: LocalizedStringResource("Attack", table: "Database"), value: item.attack))
            attributes.append(.init(name: LocalizedStringResource("Magic Attack", table: "Database"), value: item.magicAttack))
            attributes.append(.init(name: LocalizedStringResource("Attack Range", table: "Database"), value: formatCells(item.range)))
            attributes.append(.init(name: LocalizedStringResource("Slots", table: "Database"), value: item.slots))
        case .armor:
            attributes.append(.init(name: LocalizedStringResource("Defense", table: "Database"), value: item.defense))
            attributes.append(.init(name: LocalizedStringResource("Slots", table: "Database"), value: item.slots))
        default:
            break
        }

        switch item.type {
        case .weapon, .armor:
            attributes.append(.init(name: LocalizedStringResource("Gender", table: "Database"), value: item.gender.localizedName))
        default:
            break
        }

        switch item.type {
        case .weapon:
            attributes.append(.init(name: LocalizedStringResource("Weapon Level", table: "Database"), value: item.weaponLevel))
        case .armor:
            attributes.append(.init(name: LocalizedStringResource("Armor Level", table: "Database"), value: item.armorLevel))
        default:
            break
        }

        switch item.type {
        case .weapon, .armor:
            attributes.append(.init(name: LocalizedStringResource("Minimum Level", table: "Database"), value: item.equipLevelMin))
            attributes.append(.init(name: LocalizedStringResource("Maximum Level", table: "Database"), value: item.equipLevelMax))
            attributes.append(.init(name: LocalizedStringResource("Refinable", table: "Database"), value: item.refineable))
            attributes.append(.init(name: LocalizedStringResource("Gradable", table: "Database"), value: item.gradable))
            attributes.append(.init(name: LocalizedStringResource("View", table: "Database"), value: item.view))
        default:
            break;
        }

        return attributes
    }

    var localizedJobs: [String] {
        item.jobs
            .sorted(using: KeyPathComparator(\.intValue))
            .map { $0.localizedName.map { String(localized: $0) } ?? $0.stringValue }
    }

    var localizedClasses: [String] {
        OptionSetSequence(item.classes)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { String(localized: $0.localizedName) }
    }

    var localizedLocations: [String] {
        OptionSetSequence(item.locations)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { String(localized: $0.localizedName) }
    }

    init(mode: DatabaseMode, item: Item, localizedName: String?, localizedDescription: String?, resourceManager: ResourceManager) {
        self.mode = mode
        self.item = item
        self.localizedName = localizedName
        self.localizedDescription = localizedDescription
        self.resourceManager = resourceManager
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Item, Value>) -> Value {
        item[keyPath: keyPath]
    }

    @MainActor
    func fetchIconImage() async {
        if iconImage == nil {
            iconImage = try? await resourceManager.itemIconImage(forItemID: item.id)
        }
    }

    @MainActor
    func fetchPreviewImage() async {
        if previewImage == nil {
            previewImage = try? await resourceManager.itemPreviewImage(forItemID: item.id)
        }
    }
}

extension ItemModel: Equatable {
    static func == (lhs: ItemModel, rhs: ItemModel) -> Bool {
        lhs.item.id == rhs.item.id
    }
}

extension ItemModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
    }
}

extension ItemModel: Identifiable {
    var id: Int {
        item.id
    }
}
