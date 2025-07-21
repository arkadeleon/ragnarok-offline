//
//  InventoryItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/11.
//

import RONetwork
import ROResources
import SwiftUI

struct InventoryItemView<Actions>: View where Actions: View {
    var item: InventoryItem
    var actions: () -> Actions

    @State private var iconImage: CGImage?

    var body: some View {
        Menu(content: actions) {
            ZStack {
                if let iconImage {
                    Image(decorative: iconImage, scale: 1)
                }

                GameText("\(item.amount)")
                    .offset(x: 5, y: 10)
            }
            .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .task {
            let scriptContext = await ResourceManager.shared.scriptContext(for: .current)
            let pathGenerator = ResourcePathGenerator(scriptContext: scriptContext)
            if let path = pathGenerator.generateItemIconImagePath(itemID: item.itemID) {
                iconImage = try? await ResourceManager.shared.image(at: path, removesMagentaPixels: true)
            }
        }
    }

    init(item: InventoryItem, @ViewBuilder actions: @escaping () -> Actions) {
        self.item = item
        self.actions = actions
    }
}

#Preview {
    let item = {
        var item = InventoryItem()
        item.itemID = 501
        item.amount = 1
        return item
    }()

    InventoryItemView(item: item) {
        GameText("Use")
    }
    .padding()
}
