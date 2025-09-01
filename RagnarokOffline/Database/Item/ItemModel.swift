//
//  ItemModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/6.
//

import CoreGraphics
import Foundation
import Observation
import RODatabase
import RORendering
import ROResources

@Observable
@dynamicMemberLookup
final class ItemModel {
    private let mode: DatabaseMode
    private let item: Item

    var localizedName: String?
    var iconImage: CGImage?
    var previewImage: CGImage?
    var localizedDescription: AttributedString?

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
        attributes.append(.init(name: "Type", value: item.type.localizedName))

        switch item.subType {
        case .none:
            break
        case .weapon(let weaponType):
            attributes.append(.init(name: "Weapon Type", value: weaponType.localizedName))
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
            attributes.append(.init(name: "Gender", value: item.gender.localizedName))
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

    var displayLocations: String {
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

    @MainActor
    func fetchLocalizedName() async {
        let itemInfoTable = await ResourceManager.shared.itemInfoTable(for: .current)
        localizedName = itemInfoTable.localizedIdentifiedItemName(forItemID: item.id)
    }

    @MainActor
    func fetchIconImage() async {
        if iconImage == nil {
            let scriptContext = await ResourceManager.shared.scriptContext(for: .current)
            let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
            if let path = pathGenerator.generateItemIconImagePath(itemID: item.id) {
                iconImage = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
            }
        }
    }

    @MainActor
    func fetchDetail() async {
        let scriptContext = await ResourceManager.shared.scriptContext(for: .current)
        let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
        if let previewImagePath = pathGenerator.generateItemPreviewImagePath(itemID: item.id) {
            previewImage = try? await ResourceManager.shared.image(at: previewImagePath, removesMagentaPixels: true)
        }

        let itemInfoTable = await ResourceManager.shared.itemInfoTable(for: .current)
        if let itemDescription = itemInfoTable.localizedIdentifiedItemDescription(forItemID: item.id) {
            localizedDescription = AttributedString(description: itemDescription)
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
