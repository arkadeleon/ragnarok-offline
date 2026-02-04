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

    @Environment(GameSession.self) private var gameSession

    @State private var tab: InventoryTab = .item
    @State private var selectedItem: InventoryItem?

    @Namespace private var itemNamespace

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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameTitleBar()

                VStack(spacing: 0) {
                    tabBar
                    itemGrid
                }
                .background(Color.white)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
                }
                .overlay(alignment: .trailing) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
                }

                GameBottomBar()
            }
            .geometryGroup()
            .blur(radius: selectedItem == nil ? 0 : 5)
            .frame(width: 280)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedItem = nil
            }

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
        ZStack(alignment: .top) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 0)], spacing: 0) {
                ForEach(0..<64) { _ in
                    ZStack(alignment: .center) {
                        Ellipse()
                            .foregroundStyle(Color(#colorLiteral(red: 0.7960784314, green: 0.831372549, blue: 0.8980392157, alpha: 1)))
                            .frame(width: 24, height: 12)
                            .offset(y: 5)
                            .blur(radius: 2)
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .frame(width: 32 * 8, height: 32 * 8)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 0)], spacing: 0) {
                ForEach(items, id: \.index) { item in
                    InventoryItemView(item: item)
                        .matchedGeometryEffect(
                            id: item.index,
                            in: itemNamespace,
                            anchor: .bottom
                        )
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
            .frame(width: 32 * 8)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var contextMenu: some View {
        if let item = selectedItem {
            VStack {
                if item.isUsable {
                    InventoryItemActionButton(label: "Use") {
                        gameSession.useItem(at: item.index)
                        selectedItem = nil
                    }
                }

                if item.isEquippable {
                    InventoryItemActionButton(label: "Equip") {
                        gameSession.equipItem(at: item.index, location: item.location)
                        selectedItem = nil
                    }
                }

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
}

private struct InventoryItemView: View {
    var item: InventoryItem

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: CGImage?

    var body: some View {
        ZStack {
            if let iconImage {
                Image(decorative: iconImage, scale: 1)
            }

            Text(verbatim: "\(item.amount)")
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .offset(x: 5, y: 10)
        }
        .frame(width: 32, height: 32)
        .task(id: item.itemID) {
            let resourceManager = gameSession.resourceManager
            let scriptContext = await resourceManager.scriptContext()
            if let path = ResourcePath.generateItemIconImagePath(itemID: item.itemID, scriptContext: scriptContext) {
                iconImage = try? await resourceManager.image(at: path, removesMagentaPixels: true)
            }
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
        var redPotion = InventoryItem()
        redPotion.index = 0
        redPotion.itemID = 501
        redPotion.type = .healing
        redPotion.amount = 2

        var sword = InventoryItem()
        sword.index = 1
        sword.itemID = 1101
        sword.type = .weapon
        sword.amount = 1

        var inventory = Inventory()
        inventory.append(item: redPotion)
        inventory.append(item: sword)
        return inventory
    }()

    InventoryView(inventory: inventory)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
