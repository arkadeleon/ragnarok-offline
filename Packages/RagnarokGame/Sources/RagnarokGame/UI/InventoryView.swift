//
//  InventoryView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import RagnarokModels
import RagnarokResources
import SwiftUI

private enum InventoryTab {
    case item
    case gear
    case etc
}

struct InventoryView: View {
    var inventory: Inventory
    var onClose: () -> Void = {}

    @Environment(GameSession.self) private var gameSession

    @State private var tab: InventoryTab = .item
    @State private var selectedItem: InventoryItem?

    @Namespace private var itemNamespace

    var body: some View {
        ZStack {
            VStack(spacing: 3) {
                GameWindow {
                    VStack(spacing: 0) {
                        tabBar
                        itemGrid
                    }
                } titleBar: {
                    GameTitleBar(closeAction: onClose)
                }
                .geometryGroup()
                .blur(radius: selectedItem == nil ? 0 : 5)
                .frame(width: 320)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = nil
                }

                ShortcutBarView()
            }
            .shortcutDragContainer()

            contextMenu
                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
        }
        .animation(.easeInOut(duration: 0.25), value: selectedItem)
    }

    private var tabBar: some View {
        HStack {
            Button {
                tab = .item
            } label: {
                Text(verbatim: "Item")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                tab = .gear
            } label: {
                Text(verbatim: "Gear")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                tab = .etc
            } label: {
                Text(verbatim: "Etc.")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 280, height: 20)
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 4)], spacing: 4) {
                ForEach(0..<slotCount, id: \.self) { slot in
                    ZStack(alignment: .center) {
                        Ellipse()
                            .fill(Color(#colorLiteral(red: 0.7960784314, green: 0.831372549, blue: 0.8980392157, alpha: 1)))
                            .blur(radius: 2)
                            .frame(width: 24, height: 12)
                            .offset(y: 5)

                        if slot < items.count {
                            let item = items[slot]

                            InventoryItemView(item: item)
                                .contentShape(Rectangle())
                                .matchedGeometryEffect(
                                    id: item.index,
                                    in: itemNamespace,
                                    anchor: .bottom
                                )
                                .onTapGesture {
                                    selectedItem = item
                                }
                                .shortcutDragSource(.item(itemID: item.itemID))
                        }
                    }
                    .frame(width: 32, height: 32)
                }
            }
        }
        .frame(height: 32 * 6 + 4 * 5)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    @ViewBuilder private var contextMenu: some View {
        if let item = selectedItem {
            VStack {
                if item.isUsable {
                    InventoryItemActionButton(label: "Use") {
                        gameSession.useItem(at: item.index)
                        selectedItem = nil
                    }
                }

                if item.isEquippable {
                    if item.isEquipped {
                        InventoryItemActionButton(label: "Unequip") {
                            gameSession.unequipItem(at: item.index)
                            selectedItem = nil
                        }
                    } else {
                        InventoryItemActionButton(label: "Equip") {
                            gameSession.equipItem(at: item.index, location: item.location)
                            selectedItem = nil
                        }
                    }
                }

                if !item.isEquipped {
                    if item.amount > 1 {
                        InventoryItemActionButton(label: "Throw One") {
                            gameSession.throwItem(at: item.index, amount: 1)
                            selectedItem = nil
                        }

                        InventoryItemActionButton(label: "Throw All") {
                            gameSession.throwItem(at: item.index, amount: item.amount)
                            selectedItem = nil
                        }
                    } else {
                        InventoryItemActionButton(label: "Throw") {
                            gameSession.throwItem(at: item.index, amount: 1)
                            selectedItem = nil
                        }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 10).fill(Material.bar))
            .matchedGeometryEffect(
                id: item.index,
                in: itemNamespace,
                properties: .position,
                anchor: .bottom,
                isSource: false
            )
        }
    }

    private var items: [InventoryItem] {
        switch tab {
        case .item:
            inventory.usableItems
        case .gear:
            inventory.equipItems
        case .etc:
            inventory.etcItems
        }
    }

    private var slotCount: Int {
        max(items.count, 48)
    }
}

private struct InventoryItemView: View {
    var item: InventoryItem

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        ZStack {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
            }

            Text(verbatim: "\(item.amount)")
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .shadow(color: .white, radius: 1)
                .offset(x: 5, y: 10)

            if item.isEquipped {
                Text(verbatim: "E")
                    .font(.game())
                    .foregroundStyle(Color.gameProminentLabel)
                    .shadow(color: .black, radius: 1)
                    .offset(x: -10, y: -10)
            }
        }
        .frame(width: 32, height: 32)
        .task(id: item.itemID) {
            iconImage = try? await gameContext.resourceManager.itemIconImage(forItemID: item.itemID)
        }
    }
}

private struct InventoryItemActionButton: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: label)
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let inventory = {
        var inventory = Inventory()
        var index = 0

        for itemID in 501...599 {
            var item = InventoryItem()
            item.index = index
            item.itemID = itemID
            item.type = .healing
            item.amount = index + 1
            inventory.append(item: item)
            index += 1
        }

        var sword = InventoryItem()
        sword.index = index
        sword.itemID = 1101
        sword.type = .weapon
        sword.amount = 1
        inventory.append(item: sword)

        var shield = InventoryItem()
        shield.index = index + 1
        shield.itemID = 2101
        shield.type = .armor
        shield.amount = 1
        shield.location = .left_hand
        shield.equippedLocation = .left_hand
        inventory.append(item: shield)

        return inventory
    }()

    InventoryView(inventory: inventory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
        .environment(GameContext.testing)
}
