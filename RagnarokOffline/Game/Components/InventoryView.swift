//
//  InventoryView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/10.
//

import RONetwork
import SwiftUI

struct InventoryView: View {
    var inventory: Inventory

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            HStack(spacing: 0) {
                ZStack {
                    GameImage("basic_interface/itemwin_left.bmp") { image in
                        image.resizable(resizingMode: .tile)
                    }

                    VStack {
                        Button {
                        } label: {
                            GameText("I\nt\ne\nm")
                                .multilineTextAlignment(.center)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 20)

                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    ForEach(0..<8) { y in
                        GridRow {
                            ForEach(0..<7) { x in
                                itemView(at: y * 7 + x)
                            }
                        }
                    }
                }
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .background(.white)

                GameImage("basic_interface/itemwin_right.bmp") { image in
                    image.resizable(resizingMode: .tile)
                }
                .frame(width: 20)
            }
            .frame(height: 272)

            HStack(spacing: 0) {
                GameImage("basic_interface/btnbar_left.bmp")

                GameImage("basic_interface/btnbar_mid.bmp") { image in
                    image.resizable()
                }

                GameImage("basic_interface/btnbar_right.bmp")
            }
            .frame(height: 21)
        }
        .frame(width: 280)
    }

    private func itemView(at index: Int) -> InventoryItemView {
        index < inventory.stackableItems.count ? InventoryItemView(item: inventory.stackableItems[index]) : InventoryItemView()
    }
}

#Preview {
    var inventory: Inventory {
        var item1 = Inventory.StackableItem()
        item1.itemID = 501

        var item2 = Inventory.StackableItem()
        item2.itemID = 502

        var inventory = Inventory()
        inventory.stackableItems = [item1, item2]
        return inventory
    }

    InventoryView(inventory: inventory)
        .padding()
}
