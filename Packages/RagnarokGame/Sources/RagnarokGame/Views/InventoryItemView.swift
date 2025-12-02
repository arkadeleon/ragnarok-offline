//
//  InventoryItemView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/11.
//

import RagnarokNetwork
import RagnarokResources
import SwiftUI

struct InventoryItemView: View {
    var item: InventoryItem

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: CGImage?

    var body: some View {
        Menu {
            if item.isUsable {
                Button {
                    if let mapSession = gameSession.mapSession {
                        let accountID = mapSession.account.accountID
                        mapSession.useItem(at: item.index, by: accountID)
                    }
                } label: {
                    Text(verbatim: "Use")
                }
            }

            if item.isEquippable {
                Button {
                    gameSession.mapSession?.equipItem(at: item.index, location: item.location)
                } label: {
                    Text(verbatim: "Equip")
                }
            }
        } label: {
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
        .menuStyle(.button)
        .buttonStyle(.plain)
        .task {
            let resourceManager = gameSession.resourceManager
            let scriptContext = await resourceManager.scriptContext()
            if let path = ResourcePath.generateItemIconImagePath(itemID: item.itemID, scriptContext: scriptContext) {
                let image = try? await resourceManager.image(at: path)
                iconImage = image?.removingMagentaPixels()
            }
        }
    }
}

#Preview {
    let item = {
        var item = InventoryItem()
        item.itemID = 501
        item.type = .healing
        item.amount = 1
        return item
    }()

    InventoryItemView(item: item)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
