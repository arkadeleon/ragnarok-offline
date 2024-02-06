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
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(uiColor: .secondarySystemBackground))

            VStack(spacing: 0) {
                DatabaseRecordImage {
                    await ClientResourceManager.shared.monsterImage(monster.id, size: CGSize(width: 80, height: 80))
                }
                .frame(width: 80, height: 80)
                .padding(4)

                ZStack {
                    Color(uiColor: .secondarySystemBackground)
                        .clipShape(.rect(bottomLeadingRadius: 4, bottomTrailingRadius: 4))

                    Text(monster.name)
                        .lineLimit(2, reservesSpace: true)
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .label))
                        .padding(4)
                }
            }
        }
    }
}
