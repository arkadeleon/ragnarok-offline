//
//  MonsterGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import rAthenaMap
import SwiftUI

struct MonsterGridCell: View {
    let monster: RAMonster

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.monsterImage(monster.monsterID)
            }
            .frame(width: 48, height: 48)

            Text(monster.name)
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(.init(uiColor: .label))
        }
    }
}

#Preview {
    MonsterGridCell(monster: RAMonster())
}
