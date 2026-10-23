//
//  ItemGroupSourceCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct ItemGroupSourceCell: View {
    var itemGroupSource: ItemGroupSource

    var body: some View {
        ItemCell(item: itemGroupSource.item) {
            HStack(spacing: 4) {
                if itemGroupSource.subGroupListItemChance.listItem.amount > 1 {
                    AmountBadge(amount: itemGroupSource.subGroupListItemChance.listItem.amount)
                }
                ItemGroupRateBadge(probability: itemGroupSource.subGroupListItemChance.probability)
            }
        }
    }
}
