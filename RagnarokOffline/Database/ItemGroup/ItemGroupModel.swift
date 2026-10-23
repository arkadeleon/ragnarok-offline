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
        var subGroupNumber: Int
        var subGroupListItem: ItemGroup.SubGroup.ListItem
        var item: ItemModel

        /// The chance to get this item from its SubGroup, from 0 to 1. Every item of an `All` SubGroup is 1.
        var probability: Double

        var id: String {
            "\(subGroupNumber)-\(subGroupListItem.index)"
        }
    }

    private let mode: DatabaseMode
    private let itemGroup: ItemGroup

    var obtainableItems: [ObtainableItem]?

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
                    let obtainableItem = ObtainableItem(
                        subGroupNumber: subGroup.subGroup,
                        subGroupListItem: listItem,
                        item: item,
                        probability: probability
                    )
                    obtainableItems.append(obtainableItem)
                }
            }
        }

        self.obtainableItems = obtainableItems
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
