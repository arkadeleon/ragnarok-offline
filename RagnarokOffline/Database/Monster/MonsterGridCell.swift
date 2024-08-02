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

    @State private var monsterImage: CGImage?

    var body: some View {
        ImageGridCell(title: monster.localizedName, subtitle: secondaryText) {
            if let monsterImage {
                if monsterImage.width > 80 || monsterImage.height > 80 {
                    Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(monsterImage, scale: 1, label: Text(monster.localizedName))
                }
            } else {
                Image(systemName: "pawprint")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            monsterImage = await monster.fetchImage()
        }
    }
}
