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
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 25))
            }
        }
        .frame(width: 40, height: 40)
        .task {
            itemIcon = await ClientResourceBundle.shared.itemIconImage(forItem: item)
        }
    }
}

//#Preview {
//    ItemIconView()
//}
