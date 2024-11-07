//
//  MonsterGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterGridCell: View {
    var monster: ObservableMonster
    var secondaryText: String?

    var body: some View {
        ImageGridCell(title: monster.displayName, subtitle: secondaryText) {
            if let monsterImage = monster.image {
                if monsterImage.width > 80 || monsterImage.height > 80 {
                    Image(monsterImage, scale: 1, label: Text(monster.displayName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(monsterImage, scale: 1, label: Text(monster.displayName))
                }
            } else {
                Image(systemName: "pawprint")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            await monster.fetchImage()
        }
    }
}
