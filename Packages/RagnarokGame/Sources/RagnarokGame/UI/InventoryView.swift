//
//  InventoryView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/10.
//

import RagnarokCore
import RagnarokModels
import RagnarokResources
import SwiftUI

private enum InventoryTab {
    case item
    case equip
    case etc
}

struct InventoryView: View {
    var inventory: Inventory
    var onClose: () -> Void = {}

    @Environment(GameContext.self) private var gameContext

    @State private var tab: InventoryTab = .item
    @State private var selectedItem: InventoryItem?

    var body: some View {
        VStack(spacing: 3) {
            GameWindow {
                VStack(spacing: 0) {
                    tabBar
                    itemGrid
                }
            }
            .gameWindowTitle(Text(gameContext.messageStringTable.localizedMessageString(forID: 106)))
            .gameWindowCloseAction(onClose)
            .geometryGroup()
            .blur(radius: selectedItem == nil ? 0 : 5)
            .frame(width: 320)
            .overlay {
                if selectedItem != nil {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = nil
                        }
                }
            }
            .overlay {
                contextMenu
                    .transition(.opacity.combined(with: .scale).animation(.bouncy(duration: 0.25, extraBounce: 0.2)))
            }

            ShortcutBarView()
        }
        .shortcutDragContainer()
        .animation(.easeInOut(duration: 0.25), value: selectedItem)
    }

    private var tabBar: some View {
        HStack {
            // basic_interface/tab_itm_01.bmp
            Button {
                tab = .item
            } label: {
                Text(verbatim: "item")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // basic_interface/tab_itm_02.bmp
            Button {
                tab = .equip
            } label: {
                Text(verbatim: "equip")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // basic_interface/tab_itm_03.bmp
            Button {
                tab = .etc
            } label: {
                Text(verbatim: "etc")
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
        }
        .frame(height: 32 * 6 + 4 * 5)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
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

                InventoryItemActions(item: item) {
                    selectedItem = nil
                }
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

private struct InventoryItemPreview: View {
    var item: InventoryItem

    @Environment(GameContext.self) private var gameContext

    @State private var previewImage: Resources.Image?

    var body: some View {
        VStack(spacing: 3) {
            // basic_interface/collection_bg.bmp
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    InventoryItemPreviewStripeView()
                        .frame(height: 23)
                        .overlay(alignment: .bottomTrailing) {
                            Text(verbatim: "Collections")
                                .font(.game(size: 16, weight: .bold))
                                .italic()
                                .foregroundStyle(Color(#colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)))
                        }

                    Rectangle()
                        .fill(Color(#colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)))
                        .frame(height: 1)
                }

                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        if let previewImage {
                            Image(decorative: previewImage.cgImage, scale: 1)
                        }
                    }
                    .frame(width: 75, height: 100)
                    .background(Color.white)
                    .border(Color.black, width: 1)
                    .background {
                        Color(#colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1))
                            .offset(x: 2, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(itemName)
                            .font(.game(size: 11, weight: .bold))
                            .foregroundStyle(Color.gameLabel)
                            .shadow(color: .white, radius: 0, x: 1, y: 1)
                            .lineLimit(1)

                        ScrollView {
                            Text(AttributedString(description: itemDescription, defaultColor: .gameLabel))
                                .font(.game(size: 11))
                                .lineSpacing(4)
                                .padding(.top, 4)
                                .padding(.bottom, 8)
                                .padding(.trailing, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 8)
            }
            .padding(2)
            .frame(width: 280, height: 140)
            .background(RoundedRectangle(cornerRadius: 5).fill(Material.bar))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.gameBoxBorder, lineWidth: 1)
                    .padding(2)
            }

            if !cardIDs.isEmpty {
                HStack(spacing: 2) {
                    ForEach(Array(cardIDs.enumerated()), id: \.offset) { _, cardID in
                        InventoryItemCardView(cardID: cardID)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .frame(width: 280)
                .background(RoundedRectangle(cornerRadius: 5).fill(Material.bar))
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gameBoxBorder, lineWidth: 1)
                        .padding(2)
                }
            }
        }
        .task(id: item.itemID) {
            previewImage = try? await gameContext.resourceManager.itemPreviewImage(forItemID: item.itemID)
        }
    }

    private var itemName: String {
        gameContext.itemInfoTable.localizedIdentifiedItemName(forItemID: item.itemID) ?? "\(item.itemID)"
    }

    private var itemDescription: String {
        gameContext.itemInfoTable.localizedIdentifiedItemDescription(forItemID: item.itemID) ?? ""
    }

    /// Cards compounded into the equipment. The first slot marks forged and pet items instead of a card.
    private var cardIDs: [Int] {
        guard item.isEquippable, let first = item.slots.first else {
            return []
        }
        if first == 0x00FF || first == 0x00FE || first == 0xFF00 {
            return []
        }
        return item.slots.filter { $0 != 0 }
    }
}

private struct InventoryItemPreviewStripeView: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 1
            while y < size.height {
                let stripe = Path(CGRect(x: 0, y: y, width: size.width, height: 1))
                context.fill(stripe, with: .color(Color(#colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1))))
                y += 2
            }
        }
        .background(Color.white)
    }
}

private struct InventoryItemCardView: View {
    var cardID: Int

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        ZStack {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
            }
        }
        .frame(width: 24, height: 24)
        .task(id: cardID) {
            iconImage = try? await gameContext.resourceManager.itemIconImage(forItemID: cardID)
        }
    }
}

private struct InventoryItemActions: View {
    var item: InventoryItem
    var dismiss: () -> Void

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.isUsable {
                GameContextMenuButton(label: "Use") {
                    gameSession.useItem(at: item.index)
                    dismiss()
                }
            }

            if item.isEquippable {
                if item.isEquipped {
                    GameContextMenuButton(label: "Unequip") {
                        gameSession.unequipItem(at: item.index)
                        dismiss()
                    }
                } else {
                    GameContextMenuButton(label: "Equip") {
                        gameSession.equipItem(at: item.index, location: item.location)
                        dismiss()
                    }
                }
            }

            if !item.isEquipped {
                if item.amount > 1 {
                    GameContextMenuButton(label: "Throw One") {
                        gameSession.throwItem(at: item.index, amount: 1)
                        dismiss()
                    }

                    GameContextMenuButton(label: "Throw All") {
                        gameSession.throwItem(at: item.index, amount: item.amount)
                        dismiss()
                    }
                } else {
                    GameContextMenuButton(label: "Throw") {
                        gameSession.throwItem(at: item.index, amount: 1)
                        dismiss()
                    }
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
