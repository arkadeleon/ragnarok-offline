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
        VStack {
            ZStack {
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
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 35))
                }
            }
            .frame(width: 80, height: 80)

            ZStack(alignment: .top) {
                // This VStack is just for reserving space.
                VStack(spacing: 2) {
                    Text(" ")
                        .font(.subheadline)
                        .lineLimit(2, reservesSpace: true)

                    Text(" ")
                        .lineLimit(1, reservesSpace: true)
                }

                VStack(spacing: 2) {
                    Text(monster.localizedName)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .lineLimit(2, reservesSpace: false)

                    if let secondaryText {
                        Text(secondaryText)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            monsterImage = await monster.fetchImage()
        }
    }
}
