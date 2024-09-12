//
//  ItemIconView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/30.
//

import ROClient
import RODatabase
import SwiftUI

struct ItemIconView: View {
    var item: Item

    @State private var itemIcon: CGImage?

    var body: some View {
        ZStack {
            if let itemIcon {
                Image(itemIcon, scale: 1, label: Text(item.name))
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
            itemIcon = await ClientResourceManager.default.itemIconImage(forItem: item)
        }
    }
}

//#Preview {
//    ItemIconView()
//}
