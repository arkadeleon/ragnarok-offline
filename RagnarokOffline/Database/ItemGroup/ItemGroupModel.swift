//
//  ItemGroupModel.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import Observation
import RagnarokConstants
import RagnarokDatabase

@Observable
@dynamicMemberLookup
final class ItemGroupModel {
    struct ObtainableItem: Identifiable {
        var subGroupListItemChance: SubGroupListItemChance
        var item: ItemModel

        var id: String {
            subGroupListItemChance.id
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

    /// A chance to get an item from one list item of a SubGroup.
    struct SubGroupListItemChance: Identifiable {
        var subGroup: ItemGroup.SubGroup
        var listItem: ItemGroup.SubGroup.ListItem

        /// The chance to get the item, from 0 to 1. Every item of an `All` SubGroup is 1.
        var probability: Double

        var id: String {
            "\(subGroup.subGroup)-\(listItem.index)"
        }
    }

    private let mode: DatabaseMode
    private let itemGroup: ItemGroup

    var obtainableItems: [ObtainableItem]?

    /// The items whose scripts call `getgroupitem` with this group.
    var sourceItems: [ItemModel] = []

    var displayName: String {
        itemGroup.group
    }

    init(mode: DatabaseMode, itemGroup: ItemGroup) {
        self.mode = mode
        self.itemGroup = itemGroup
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<ItemGroup, Value>) -> Value {
        itemGroup[keyPath: keyPath]
    }

    @MainActor
    func fetchDetail(database: DatabaseModel) async {
        var obtainableItems: [ObtainableItem] = []

        for subGroup in itemGroup.subGroups.sorted(by: { $0.subGroup < $1.subGroup }) {
            let totalRate = subGroup.list.reduce(0) { $0 + $1.rate }
            for listItem in subGroup.list {
                if let item = await database.item(forAegisName: listItem.item) {
                    let probability = subGroup.algorithm == .all ? 1 : Double(listItem.rate) / Double(max(totalRate, 1))
                    let subGroupListItemChance = SubGroupListItemChance(subGroup: subGroup, listItem: listItem, probability: probability)
                    let obtainableItem = ObtainableItem(subGroupListItemChance: subGroupListItemChance, item: item)
                    obtainableItems.append(obtainableItem)
                }
            }
        }

        self.obtainableItems = obtainableItems
    }

    func highestSubGroupListItemChance(forItemAegisName itemAegisName: String) -> SubGroupListItemChance? {
        subGroupListItemChances(forItemAegisName: itemAegisName)
            .max(by: { $0.probability < $1.probability })
    }

    func subGroupListItemChances(forItemAegisName itemAegisName: String) -> [SubGroupListItemChance] {
        var subGroupListItemChances: [SubGroupListItemChance] = []

        for subGroup in itemGroup.subGroups.sorted(by: { $0.subGroup < $1.subGroup }) {
            let totalRate = subGroup.list.reduce(0) { $0 + $1.rate }
            for listItem in subGroup.list where listItem.item == itemAegisName {
                let probability = subGroup.algorithm == .all ? 1 : Double(listItem.rate) / Double(max(totalRate, 1))
                let chance = SubGroupListItemChance(subGroup: subGroup, listItem: listItem, probability: probability)
                subGroupListItemChances.append(chance)
            }
        }

        return subGroupListItemChances
    }
}

extension ItemGroupModel: Equatable {
    static func == (lhs: ItemGroupModel, rhs: ItemGroupModel) -> Bool {
        lhs.itemGroup.group == rhs.itemGroup.group
    }
}

extension ItemGroupModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemGroup.group)
    }
}
