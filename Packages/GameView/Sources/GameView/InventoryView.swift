//
//  InventoryView.swift
//  GameView
//
//  Created by Leon Li on 2025/4/10.
//

import GameCore
import NetworkClient
import SwiftUI

struct InventoryView: View {
    var inventory: Inventory

    @Environment(GameSession.self) private var gameSession

    @State private var items: [InventoryItem] = []

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
                        items = inventory.usableItems
                    } label: {
                        Text(verbatim: "I\nt\ne\nm")
                            .gameText()
                            .multilineTextAlignment(.center)
                            .frame(height: 66)
                    }
                    .buttonStyle(.borderless)

                    Button {
                        items = inventory.equippableItems
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
                        InventoryItemView(item: item) {
                            if item.isUsable {
                                Button {
                                    gameSession.useItem(item)
                                } label: {
                                    Text(verbatim: "Use")
                                }
                            }

                            if item.isEquippable {
                                Button {
                                    gameSession.equipItem(item)
                                } label: {
                                    Text(verbatim: "Equip")
                                }
                            }
                        }
                    }
                }
                .frame(width: 32 * 7)
                .offset(x: 36)
            }
            .frame(height: 264)

            GameBottomBar()
        }
        .frame(width: 280)
        .task {
            items = inventory.usableItems
        }
    }
}

#Preview {
    let inventory = {
        var item1 = InventoryItem()
        item1.index = 0
        item1.itemID = 501
        item1.type = .healing

        var item2 = InventoryItem()
        item2.index = 1
        item2.itemID = 502
        item2.type = .healing

        var inventory = Inventory()
        inventory.append(items: [item1, item2])
        return inventory
    }()

    InventoryView(inventory: inventory)
        .padding()
        .environment(GameSession.previewing)
}
