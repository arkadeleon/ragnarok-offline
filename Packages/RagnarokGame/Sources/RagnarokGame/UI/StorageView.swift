//
//  StorageView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/28.
//

import RagnarokModels
import SwiftUI

private enum StorageTab: CaseIterable {
    case item
    case cash
    case armor
    case weapon
    case ammo
    case card
    case misc

    init(item: InventoryItem) {
        switch item.type {
        case .healing, .usable, .delayconsume:
            self = .item
        case .cash:
            self = .cash
        case .armor, .shadowgear, .petegg:
            self = .armor
        case .weapon, .petarmor:
            self = .weapon
        case .ammo:
            self = .ammo
        case .card:
            self = .card
        default:
            self = .misc
        }
    }
}

private enum StorageSelectedItem: Equatable {
    case storage(InventoryItem)
    case inventory(InventoryItem)
}

struct StorageView: View {
    var storage: Storage

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var storageTab: StorageTab = .item
    @State private var inventoryTab: InventoryTab = .item
    @State private var selectedItem: StorageSelectedItem?
    @State private var movingItem: StorageSelectedItem?

    var body: some View {
        GameWindow {
            HStack(alignment: .top, spacing: 0) {
                storageTabBar

                StorageItemList(items: storageItems) { item in
                    selectedItem = .storage(item)
                }

                inventoryTabBar

                StorageItemGrid(items: inventoryItems) { item in
                    selectedItem = .inventory(item)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        } bottomBar: {
            GameBottomBar {
                Text(verbatim: "\(storage.amount)/\(storage.maxAmount)")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)

                Spacer()
            }
        }
        .gameWindowTitle(Text(verbatim: storage.name))
        .gameWindowCloseAction {
            gameSession.closeStorage()
        }
        .geometryGroup()
        .blur(radius: selectedItem == nil && movingItem == nil ? 0 : 5)
        .frame(width: 320)
        .overlay {
            if selectedItem != nil || movingItem != nil {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = nil
                        movingItem = nil
                    }
            }
        }
        .overlay {
            contextMenu
                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
        }
        .overlay {
            moveAmountInputBox
                .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
        }
        .animation(.easeInOut(duration: 0.25), value: selectedItem)
        .animation(.easeInOut(duration: 0.25), value: movingItem)
    }

    private var storageTabBar: some View {
        GameVerticalTabBar(tabs: StorageTab.allCases, selection: $storageTab) { tab in
            switch tab {
            case .item:
                // basic_interface/tab_itm_ex_01.bmp
                Text(verbatim: "item")
            case .cash:
                // basic_interface/tab_itm_ex_02.bmp
                Text(verbatim: "cash")
            case .armor:
                // basic_interface/tab_itm_ex_03.bmp
                Text(verbatim: "armor")
            case .weapon:
                // basic_interface/tab_itm_ex_04.bmp
                Text(verbatim: "weapon")
            case .ammo:
                // basic_interface/tab_itm_ex_05.bmp
                Text(verbatim: "ammo")
            case .card:
                // basic_interface/tab_itm_ex_06.bmp
                Text(verbatim: "card")
            case .misc:
                // basic_interface/tab_itm_ex_07.bmp
                Text(verbatim: "misc")
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            GameStripeView()
        }
    }

    private var inventoryTabBar: some View {
        GameVerticalTabBar(tabs: InventoryTab.allCases, selection: $inventoryTab) { tab in
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
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.gameBoxBorder)
                .frame(width: 1)
        }
    }

    @ViewBuilder private var contextMenu: some View {
        switch selectedItem {
        case .storage(let item):
            VStack(alignment: .leading, spacing: 3) {
                preview(for: item)

                StorageItemActions(item: item, isInStorage: true, movingItem: $movingItem) {
                    selectedItem = nil
                }
            }
        case .inventory(let item):
            VStack(alignment: .leading, spacing: 3) {
                preview(for: item)

                if !item.isEquipped {
                    StorageItemActions(item: item, isInStorage: false, movingItem: $movingItem) {
                        selectedItem = nil
                    }
                }
            }
        case nil:
            EmptyView()
        }
    }

    @ViewBuilder private var moveAmountInputBox: some View {
        switch movingItem {
        case .storage(let item):
            GameNumberInputBox(itemName(for: item), bounds: 1...item.amount) { amount in
                gameSession.moveItemFromStorage(index: item.index, amount: amount)
                movingItem = nil
            } onClose: {
                movingItem = nil
            }
        case .inventory(let item):
            GameNumberInputBox(itemName(for: item), bounds: 1...item.amount) { amount in
                gameSession.moveItemToStorage(index: item.index, amount: amount)
                movingItem = nil
            } onClose: {
                movingItem = nil
            }
        case nil:
            EmptyView()
        }
    }

    private var storageItems: [InventoryItem] {
        storage.items.values
            .filter({ StorageTab(item: $0) == storageTab })
            .sorted()
    }

    private var inventoryItems: [InventoryItem] {
        switch inventoryTab {
        case .item:
            gameContext.inventory.usableItems
        case .equip:
            gameContext.inventory.equipItems
        case .etc:
            gameContext.inventory.etcItems
        }
    }

    private func itemName(for item: InventoryItem) -> String {
        gameContext.itemInfoTable.localizedIdentifiedItemName(forItemID: item.itemID) ?? "\(item.itemID)"
    }

    private func preview(for item: InventoryItem) -> some View {
        InventoryItemPreview(item: item)
            .overlay(alignment: .topTrailing) {
                GameCloseButton {
                    selectedItem = nil
                }
            }
    }
}

private struct StorageItemList: View {
    var items: [InventoryItem]
    var onSelect: (InventoryItem) -> Void

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: 5) {
                        ZStack(alignment: .center) {
                            GameItemShadowView()
                                .offset(y: 5)

                            if row < items.count {
                                InventoryItemView(item: items[row])
                            }
                        }
                        .frame(width: 32, height: 32)

                        if row < items.count {
                            Text(itemName(for: items[row]))
                                .font(.game())
                                .foregroundStyle(Color.gameLabel)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if row < items.count {
                            onSelect(items[row])
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32 * 8 + 4 * 7 + 8 * 2)
    }

    private var rowCount: Int {
        max(items.count, 8)
    }

    private func itemName(for item: InventoryItem) -> String {
        gameContext.itemInfoTable.localizedIdentifiedItemName(forItemID: item.itemID) ?? "\(item.itemID)"
    }
}

private struct StorageItemGrid: View {
    var items: [InventoryItem]
    var onSelect: (InventoryItem) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(32), spacing: 4), count: 3), spacing: 4) {
                ForEach(0..<slotCount, id: \.self) { slot in
                    ZStack(alignment: .center) {
                        GameItemShadowView()
                            .offset(y: 5)

                        if slot < items.count {
                            let item = items[slot]

                            InventoryItemView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelect(item)
                                }
                        }
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32 * 8 + 4 * 7 + 8 * 2)
    }

    private var slotCount: Int {
        max(items.count, 24)
    }
}

private struct StorageItemActions: View {
    var item: InventoryItem
    var isInStorage: Bool
    @Binding var movingItem: StorageSelectedItem?
    var dismiss: () -> Void

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GameContextMenuButton(label: isInStorage ? "Take" : "Store") {
                dismiss()
                if item.amount > 1 {
                    movingItem = isInStorage ? .storage(item) : .inventory(item)
                } else if isInStorage {
                    gameSession.moveItemFromStorage(index: item.index, amount: 1)
                } else {
                    gameSession.moveItemToStorage(index: item.index, amount: 1)
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
    let context = GameContext.testing

    let storage = {
        var storage = Storage(name: "Storage")
        storage.maxAmount = 600

        for (index, itemID) in (501...520).enumerated() {
            var item = InventoryItem()
            item.index = index + 1
            item.itemID = itemID
            item.type = .healing
            item.amount = index + 1
            storage.items[item.index] = item
        }

        storage.amount = storage.items.count
        return storage
    }()

    for (index, itemID) in (601...610).enumerated() {
        var item = InventoryItem()
        item.index = index + 2
        item.itemID = itemID
        item.type = .usable
        item.amount = 5
        context.inventory.append(item: item)
    }

    return StorageView(storage: storage)
        .padding()
        .environment(GameSession.testing)
        .environment(context)
}
