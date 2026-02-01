//
//  MonsterImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//

import SwiftUI

struct MonsterImageView: View {
    var monster: MonsterModel

    var body: some View {
        ZStack {
            if let animatedImage = monster.animatedImage, let firstFrame = animatedImage.firstFrame {
                if animatedImage.frameWidth > 80 || animatedImage.frameHeight > 120 {
                    Image(firstFrame, scale: animatedImage.scale, label: Text(monster.displayName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                } else {
                    Image(firstFrame, scale: animatedImage.scale, label: Text(monster.displayName))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            } else {
                Image(systemName: "pawprint")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 80, height: 120)
        .task {
            await monster.fetchAnimatedImage()
        }
    }
}
