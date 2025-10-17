//
//  InventoryItemView.swift
//  GameView
//
//  Created by Leon Li on 2025/4/11.
//

import GameCore
import NetworkClient
import ResourceManagement
import SwiftUI

struct InventoryItemView<Actions>: View where Actions: View {
    var item: InventoryItem
    var actions: () -> Actions

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: CGImage?

    var body: some View {
        Menu(content: actions) {
            ZStack {
                if let iconImage {
                    Image(decorative: iconImage, scale: 1)
                }

                Text(verbatim: "\(item.amount)")
                    .gameText()
                    .offset(x: 5, y: 10)
            }
            .frame(width: 32, height: 32)
        }
        .buttonStyle(.borderless)
        .task {
            let resourceManager = gameSession.resourceManager
            let scriptContext = await resourceManager.scriptContext()
            if let path = ResourcePath.generateItemIconImagePath(itemID: item.itemID, scriptContext: scriptContext) {
                let image = try? await resourceManager.image(at: path)
                iconImage = image?.removingMagentaPixels()
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
        Text(verbatim: "Use")
    }
    .environment(GameSession.previewing)
}
