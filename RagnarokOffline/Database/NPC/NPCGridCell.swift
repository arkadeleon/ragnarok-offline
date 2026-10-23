//
//  NPCGridCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import SwiftUI

struct NPCGridCell: View {
    var npc: NPCModel
    var badges: [DatabaseBadge]

    var body: some View {
        ImageGridCell(title: npc.displayName, badges: badges) {
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
