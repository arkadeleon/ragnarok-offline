//
//  NPCGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import SwiftUI

struct NPCGridCell<Subtitle>: View where Subtitle: View {
    var npc: NPCModel
    @ViewBuilder var subtitle: Subtitle

    var body: some View {
        ImageGridCell(title: npc.displayName) {
            subtitle
        } image: {
            ZStack {
                if let animatedImage = npc.animatedImage, let firstFrame = animatedImage.firstFrame {
                    Image(firstFrame, scale: animatedImage.scale, label: Text(npc.displayName))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 50, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(width: 80, height: 120)
        }
        .task {
            await npc.fetchAnimatedImage()
        }
    }
}
