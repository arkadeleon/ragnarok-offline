//
//  MonsterGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaDatabase

struct MonsterGridCell: View {
    let monster: Monster

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.monsterImage(monster.id)
            }
            .frame(width: 64, height: 64)

            Text(monster.name)
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(.init(uiColor: .label))
        }
    }
}
