//
//  MonsterSummonGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/21.
//

import SwiftUI

struct MonsterSummonGridCell: View {
    var summonMonster: MonsterSummonModel.Summon

    var body: some View {
        ImageGridCell(title: summonMonster.monster.displayName) {
            HStack(spacing: 4) {
                if summonMonster.isDefault {
                    DefaultBadge()
                }
                if let rate = summonMonster.rate {
                    SummonRateBadge(rate: rate)
                }
            }
        } image: {
            MonsterImageView(monster: summonMonster.monster)
        }
    }
}
