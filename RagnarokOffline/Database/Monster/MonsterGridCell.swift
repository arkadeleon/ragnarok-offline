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
            if let animatedImage = monster.animatedImage, let firstFrame = animatedImage.firstFrame {
                if animatedImage.frameWidth / animatedImage.frameScale > 80 ||
                    animatedImage.frameHeight / animatedImage.frameScale > 80 {
                    Image(firstFrame, scale: animatedImage.frameScale, label: Text(monster.displayName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(firstFrame, scale: animatedImage.frameScale, label: Text(monster.displayName))
                }
            } else {
                Image(systemName: "pawprint")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .task {
            await monster.fetchAnimatedImage()
        }
    }
}
