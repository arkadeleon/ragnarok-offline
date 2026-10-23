//
//  ItemGroupObtainableItemCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ItemGroupObtainableItemCell: View {
    var obtainableItem: ItemGroupModel.ObtainableItem

    var body: some View {
        ItemCell(item: obtainableItem.item) {
            HStack(spacing: 4) {
                if obtainableItem.subGroupListItemChance.listItem.amount > 1 {
                    AmountBadge(amount: obtainableItem.subGroupListItemChance.listItem.amount)
                }
                ItemGroupRateBadge(probability: obtainableItem.subGroupListItemChance.probability)
            }
        }
    }
}
