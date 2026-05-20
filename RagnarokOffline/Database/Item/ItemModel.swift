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

        attributes.append(.init(name: LocalizedStringResource("ID", table: "Database"), value: "#\(item.id)"))
        attributes.append(.init(name: LocalizedStringResource("Aegis Name", table: "Database"), value: item.aegisName))
        attributes.append(.init(name: LocalizedStringResource("Name", table: "Database"), value: item.name))
        attributes.append(.init(name: LocalizedStringResource("Type", table: "Database"), value: item.type.localizedName))

        switch item.subType {
        case .none:
            break
        case .weapon(let weaponType):
            attributes.append(.init(name: LocalizedStringResource("Weapon Type", table: "Database"), value: weaponType.localizedName))
        case .ammo(let ammoType):
            attributes.append(.init(name: LocalizedStringResource("Ammo Type", table: "Database"), value: ammoType.stringValue))
        case .card(let cardType):
            attributes.append(.init(name: LocalizedStringResource("Card Type", table: "Database"), value: cardType.stringValue))
        }

        attributes.append(.init(name: LocalizedStringResource("Buy", table: "Database"), value: item.buy.formatted() + "z"))
        attributes.append(.init(name: LocalizedStringResource("Sell", table: "Database"), value: item.sell.formatted() + "z"))
        attributes.append(.init(name: LocalizedStringResource("Weight", table: "Database"), value: Double(item.weight) / 10))

        switch item.type {
        case .weapon:
            attributes.append(.init(name: LocalizedStringResource("Attack", table: "Database"), value: item.attack))
            attributes.append(.init(name: LocalizedStringResource("Magic Attack", table: "Database"), value: item.magicAttack))
            attributes.append(.init(name: LocalizedStringResource("Attack Range", table: "Database"), value: item.range))
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

    var displayLocations: String {
        OptionSetSequence(item.locations)
            .sorted(using: KeyPathComparator(\.rawValue))
            .map { "- \($0.stringValue)" }
            .joined(separator: "\n")
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
