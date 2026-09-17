//
//  NPCShopView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/17.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
import SwiftUI

struct NPCShopView: View {
    var shop: NPCShop

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    /// Selected amount per entry key.
    @State private var amounts: [Int : Int] = [:]

    var body: some View {
        GameWindow {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(entries, id: \.key) { entry in
                        NPCShopItemRow(entry: entry, amount: amountBinding(for: entry))
                    }
                }
            }
            .frame(height: 220)
        } titleBar: {
            GameTitleBar {
                gameSession.closeNPCShop()
            }
        } bottomBar: {
            GameBottomBar {
                Text(verbatim: "Total : \(total) Zeny")
                    .font(.game())
                    .foregroundStyle(Color.gameLabel)

                Spacer()

                switch shop {
                case .buy:
                    Button("buy") {
                        buy()
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                    .disabled(total == 0)
                case .sell:
                    Button("sell") {
                        sell()
                    }
                    .buttonStyle(.game)
                    .frame(width: 42, height: 20)
                    .disabled(total == 0)
                }

                Button("cancel") {
                    gameSession.closeNPCShop()
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .frame(width: 320)
        .onChange(of: shop) {
            amounts = [:]
        }
    }

    private var entries: [NPCShopEntry] {
        switch shop {
        case .buy(let items):
            items.map { item in
                NPCShopEntry(key: item.itemID, itemID: item.itemID, unitPrice: item.unitPrice, availableAmount: nil)
            }
        case .sell(let items):
            // Skip entries whose inventory slot is unknown.
            items.compactMap { item in
                guard let inventoryItem = gameContext.inventory.items[item.index] else {
                    return nil
                }
                return NPCShopEntry(key: item.index, itemID: inventoryItem.itemID, unitPrice: item.unitPrice, availableAmount: inventoryItem.amount)
            }
        }
    }

    private var total: Int {
        entries.reduce(0) { $0 + (amounts[$1.key] ?? 0) * $1.unitPrice }
    }

    private func amountBinding(for entry: NPCShopEntry) -> Binding<Int> {
        Binding {
            amounts[entry.key] ?? 0
        } set: { newValue in
            var amount = max(newValue, 0)

            if let availableAmount = entry.availableAmount {
                amount = min(amount, availableAmount)
            }

            if case .buy = shop {
                let otherTotal = total - (amounts[entry.key] ?? 0) * entry.unitPrice
                let affordableAmount = entry.unitPrice > 0 ? (gameContext.playerStatus.zeny - otherTotal) / entry.unitPrice : amount
                if amount > affordableAmount {
                    amount = max(affordableAmount, 0)
                    gameContext.messageCenter.addInsufficientZenyMessage()
                }
            }

            amounts[entry.key] = amount
        }
    }

    private func buy() {
        let purchases = entries.compactMap { entry -> NPCShopPurchase? in
            guard let amount = amounts[entry.key], amount > 0 else {
                return nil
            }
            return NPCShopPurchase(itemID: entry.key, amount: amount)
        }
        gameSession.purchaseItems(purchases)
    }

    private func sell() {
        let sales = entries.compactMap { entry -> NPCShopSale? in
            guard let amount = amounts[entry.key], amount > 0 else {
                return nil
            }
            return NPCShopSale(index: entry.key, amount: amount)
        }
        gameSession.sellItems(sales)
    }
}

/// A row in the shop list. `key` is the item ID when buying and the inventory index when selling.
private struct NPCShopEntry: Hashable {
    var key: Int
    var itemID: Int
    var unitPrice: Int
    var availableAmount: Int?
}

private struct NPCShopItemRow: View {
    var entry: NPCShopEntry

    @Binding var amount: Int

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        HStack(spacing: 5) {
            ZStack(alignment: .center) {
                GameItemShadowView()
                    .offset(y: 5)

                if let iconImage {
                    Image(decorative: iconImage.cgImage, scale: 1)
                }

                if let availableAmount = entry.availableAmount {
                    Text(verbatim: "\(availableAmount)")
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .shadow(color: .white, radius: 1)
                        .offset(x: 5, y: 10)
                }
            }
            .frame(width: 32, height: 32)

            Text(gameContext.itemInfoTable.localizedIdentifiedItemName(forItemID: entry.itemID) ?? "\(entry.itemID)")
                .lineLimit(2)

            Spacer(minLength: 5)

            Text(verbatim: "\(entry.unitPrice) Z")
                .lineLimit(1)

            GameStepper(value: $amount, in: 0...(entry.availableAmount ?? Int.max))
                .padding(.horizontal, 5)
        }
        .font(.game())
        .foregroundStyle(Color.gameLabel)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(amount > 0 ? Color(#colorLiteral(red: 0.8039215686, green: 0.8784313725, blue: 1, alpha: 1)) : .clear)
        .task(id: entry.itemID) {
            iconImage = try? await gameContext.resourceManager.itemIconImage(forItemID: entry.itemID)
        }
    }
}

#Preview("Buy") {
    let shop = NPCShop.buy([
        NPCShopBuyItem(itemID: 501, price: 50, discountPrice: 38, type: .healing, location: EquipPositions(rawValue: 0)),
        NPCShopBuyItem(itemID: 502, price: 200, discountPrice: 152, type: .healing, location: EquipPositions(rawValue: 0)),
        NPCShopBuyItem(itemID: 1101, price: 100, discountPrice: 0, type: .weapon, location: .right_hand),
    ])

    NPCShopView(shop: shop)
        .padding()
        .environment(GameSession.testing)
        .environment(GameContext.testing)
}

#Preview("Sell") {
    let context = GameContext.testing

    let shop: NPCShop = {
        var potion = InventoryItem()
        potion.index = 2
        potion.itemID = 501
        potion.type = .healing
        potion.amount = 12
        context.inventory.append(item: potion)

        var sword = InventoryItem()
        sword.index = 3
        sword.itemID = 1101
        sword.type = .weapon
        sword.amount = 1
        context.inventory.append(item: sword)

        return .sell([
            NPCShopSellItem(index: 2, price: 25, overcharge: 30),
            NPCShopSellItem(index: 3, price: 50, overcharge: 0),
            NPCShopSellItem(index: 99, price: 10, overcharge: 0),
        ])
    }()

    NPCShopView(shop: shop)
        .padding()
        .environment(GameSession.testing)
        .environment(context)
}
