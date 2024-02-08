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
    let database: Database
    let monster: Monster

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.monsterImage(monster.id, size: CGSize(width: 80, height: 80))
            }
            .frame(width: 80, height: 80)

            Text(monster.name)
                .lineLimit(2, reservesSpace: true)
                .font(.subheadline)
                .foregroundColor(Color(uiColor: .label))
        }
    }
}
