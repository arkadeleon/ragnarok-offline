//
//  InventoryView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import RagnarokModels
import SwiftUI

struct InventoryView: View {
    var inventory: Inventory

    @Environment(GameSession.self) private var gameSession

    private enum Tab {
        case item
        case gear
    }

    @State private var tab: InventoryView.Tab = .item

    private var items: [InventoryItem] {
        switch tab {
        case .item:
            inventory.usableItems
        case .gear:
            inventory.equippableItems
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    GameImage("basic_interface/itemwin_left.bmp") { image in
                        image.resizable(resizingMode: .tile)
                    }
                    .frame(width: 20)

                    GameImage("basic_interface/itemwin_mid.bmp") { image in
                        image.resizable(resizingMode: .tile)
                    }
                    .offset(x: 16)

                    GameImage("basic_interface/itemwin_right.bmp") { image in
                        image.resizable(resizingMode: .tile)
                    }
                    .frame(width: 20)
                }
                .background(.white)

                VStack {
                    Button {
                        tab = .item
                    } label: {
                        Text(verbatim: "I\nt\ne\nm")
                            .gameText()
                            .multilineTextAlignment(.center)
                            .frame(height: 66)
                    }
                    .buttonStyle(.borderless)

                    Button {
                        tab = .gear
                    } label: {
                        Text(verbatim: "G\ne\na\nr")
                            .gameText()
                            .multilineTextAlignment(.center)
                            .frame(height: 66)
                    }
                    .buttonStyle(.borderless)
                }
                .frame(width: 20, height: 264)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 0)], spacing: 0) {
                    ForEach(items, id: \.index) { item in
                        InventoryItemView(item: item)
                    }
                }
                .frame(width: 32 * 7)
                .offset(x: 36)
            }
            .frame(height: 264)

            GameBottomBar()
        }
        .frame(width: 280)
    }
}

#Preview {
    let inventory = {
        var item1 = InventoryItem()
        item1.index = 0
        item1.itemID = 501
        item1.type = .healing
        item1.amount = 1

        var item2 = InventoryItem()
        item2.index = 1
        item2.itemID = 502
        item2.type = .healing
        item2.amount = 2

        var inventory = Inventory()
        inventory.items[0] = item1
        inventory.items[1] = item2
        return inventory
    }()

    InventoryView(inventory: inventory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
