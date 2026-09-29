//
//  InventoryView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import RagnarokModels
import SwiftUI

enum InventoryTab: CaseIterable {
    case item
    case equip
    case etc
}

struct InventoryView: View {
    var inventory: Inventory
    var onClose: () -> Void = {}

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var tab: InventoryTab = .item
    @State private var selectedItem: InventoryItem?
    @State private var throwingItem: InventoryItem?

    var body: some View {
        VStack(spacing: 3) {
            GameWindow {
                HStack(alignment: .top, spacing: 0) {
                    tabBar
                    itemGrid
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .gameWindowTitle(Text(gameContext.messageStringTable.localizedMessageString(forID: 106)))
            .gameWindowCloseAction(onClose)
            .geometryGroup()
            .blur(radius: selectedItem == nil && throwingItem == nil ? 0 : 5)
            .frame(width: 320)
            .overlay {
                if selectedItem != nil || throwingItem != nil {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = nil
                            throwingItem = nil
                        }
                }
            }
            .overlay {
                contextMenu
                    .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
            }
            .overlay {
                throwAmountInputBox
                    .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
            }

            ShortcutBarView()
        }
        .shortcutDragContainer()
        .animation(.easeInOut(duration: 0.25), value: selectedItem)
        .animation(.easeInOut(duration: 0.25), value: throwingItem)
    }

    private var tabBar: some View {
        GameVerticalTabBar(tabs: InventoryTab.allCases, selection: $tab) { tab in
            switch tab {
            case .item:
                // basic_interface/tab_itm_01.bmp
                Text(verbatim: "item")
            case .equip:
                // basic_interface/tab_itm_02.bmp
                Text(verbatim: "equip")
            case .etc:
                // basic_interface/tab_itm_03.bmp
                Text(verbatim: "etc")
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            GameStripeView()
        }
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 4)], spacing: 4) {
                ForEach(0..<slotCount, id: \.self) { slot in
                    // basic_interface/itemwin_mid.bmp
                    ZStack(alignment: .center) {
                        GameItemShadowView()
                            .offset(y: 5)

                        if slot < items.count {
                            let item = items[slot]

                            InventoryItemView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = item
                                }
                                .shortcutDragSource(.item(itemID: item.itemID))
                        }
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(height: 32 * 6 + 4 * 5 + 8 * 2)
    }

    @ViewBuilder private var contextMenu: some View {
        if let item = selectedItem {
            VStack(alignment: .leading, spacing: 3) {
                InventoryItemPreview(item: item)
                    .overlay(alignment: .topTrailing) {
                        GameCloseButton {
                            selectedItem = nil
                        }
                    }

                InventoryItemActions(item: item, throwingItem: $throwingItem) {
                    selectedItem = nil
                }
            }
        }
    }

    @ViewBuilder private var throwAmountInputBox: some View {
        if let item = throwingItem {
            GameNumberInputBox(
                gameContext.itemInfoTable.localizedIdentifiedItemName(forItemID: item.itemID) ?? "\(item.itemID)",
                bounds: 1...item.amount
            ) { amount in
                gameSession.throwItem(at: item.index, amount: amount)
                throwingItem = nil
            } onClose: {
                throwingItem = nil
            }
        }
    }

    private var items: [InventoryItem] {
        switch tab {
        case .item:
            inventory.usableItems
        case .equip:
            inventory.equipItems
        case .etc:
            inventory.etcItems
        }
    }

    private var slotCount: Int {
        max(items.count, 48)
    }
}

private struct InventoryItemActions: View {
    var item: InventoryItem
    @Binding var throwingItem: InventoryItem?
    var dismiss: () -> Void

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.isUsable {
                GameContextMenuButton {
                    gameSession.useItem(at: item.index)
                    dismiss()
                } label: {
                    Text("Use", bundle: #bundle)
                }
            }

            if item.isEquippable {
                if item.isEquipped {
                    GameContextMenuButton {
                        gameSession.unequipItem(at: item.index)
                        dismiss()
                    } label: {
                        Text("Unequip", bundle: #bundle)
                    }
                } else {
                    GameContextMenuButton {
                        gameSession.equipItem(at: item.index, location: item.location)
                        dismiss()
                    } label: {
                        Text("Equip", bundle: #bundle)
                    }
                }
            }

            if !item.isEquipped {
                GameContextMenuButton {
                    dismiss()
                    if item.amount > 1 {
                        throwingItem = item
                    } else {
                        gameSession.throwItem(at: item.index, amount: 1)
                    }
                } label: {
                    Text("Throw", bundle: #bundle)
                }
            }
        }
        .frame(width: 120)
        .background(RoundedRectangle(cornerRadius: 5).fill(Material.bar))
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gameBoxBorder, lineWidth: 1)
                .padding(2)
        }
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
        sword.slots = [4001, 4002, 0, 0]
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
        .padding()
        .environment(GameSession.testing)
        .environment(GameContext.testing)
}
