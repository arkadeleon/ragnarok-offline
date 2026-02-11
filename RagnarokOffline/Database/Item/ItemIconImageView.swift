//
//  ItemIconImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import SwiftUI

struct ItemIconImageView: View {
    var item: ItemModel

    var body: some View {
        ZStack {
            if let itemIconImage = item.iconImage {
                Image(decorative: itemIconImage.cgImage, scale: 1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "leaf")
                    .font(.system(size: 25, weight: .thin))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 40, height: 40)
        .task {
            await item.fetchIconImage()
        }
    }
}
