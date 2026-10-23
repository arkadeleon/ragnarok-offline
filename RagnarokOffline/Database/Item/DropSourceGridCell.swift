//
//  DropSourceGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct DropSourceGridCell: View {
    var dropSource: DropSource

    var body: some View {
        ImageGridCell(title: dropSource.monster.displayName) {
            HStack(spacing: 4) {
                RateBadge(rate: dropSource.drop.rate)
                if dropSource.isMVPDrop {
                    MVPBadge()
                }
            }
        } image: {
            MonsterImageView(monster: dropSource.monster)
        }
    }
}
