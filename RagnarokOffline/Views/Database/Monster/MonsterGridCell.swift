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
    let secondaryText: Text?

    var body: some View {
        VStack {
            DatabaseRecordImage {
                await ClientResourceManager.shared.monsterImage(monster.id, size: CGSize(width: 80, height: 80))
            }
            .frame(width: 80, height: 80)

            Text(monster.name)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.primary)
                .font(.subheadline)
                .lineLimit(2)

            secondaryText
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    init(database: Database, monster: Monster) {
        self.database = database
        self.monster = monster
        self.secondaryText = nil
    }

    init(database: Database, monster: Monster, @ViewBuilder secondaryText: () -> Text) {
        self.database = database
        self.monster = monster
        self.secondaryText = secondaryText()
    }
}
