//
//  InventoryItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/11.
//

import RONetwork
import ROResources
import SwiftUI

struct InventoryItemView: View {
    enum Item {
        case none
        case stackable(Inventory.StackableItem)
        case equippable(Inventory.EquippableItem)
    }

    var item: InventoryItemView.Item

    @State private var iconImage: CGImage?
    @State private var count: Int?

    var body: some View {
        ZStack {
            GameImage("basic_interface/itemwin_mid.bmp")

            if let iconImage {
                Image(decorative: iconImage, scale: 1)
            }

            if let count {
                GameText("\(count)")
                    .offset(x: 5, y: 10)
            }
        }
        .frame(width: 32, height: 32)
        .task {
            switch item {
            case .none:
                break
            case .stackable(let item):
                if let path = await ResourcePath(itemIconImagePathWithItemID: item.itemID) {
                    iconImage = try? await ResourceManager.default.image(at: path, removesMagentaPixels: true)
                }
                count = item.count
            case .equippable(let item):
                if let path = await ResourcePath(itemIconImagePathWithItemID: item.itemID) {
                    iconImage = try? await ResourceManager.default.image(at: path, removesMagentaPixels: true)
                }
                count = nil
            }
        }
    }

    init() {
        self.item = .none
    }

    init(item: Inventory.StackableItem) {
        self.item = .stackable(item)
    }

    init(item: Inventory.EquippableItem) {
        self.item = .equippable(item)
    }
}

#Preview {
    let item = {
        var item = Inventory.StackableItem()
        item.itemID = 501
        item.count = 1
        return item
    }()

    InventoryItemView(item: item)
        .padding()
}
