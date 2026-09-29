//
//  InventoryItemView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/28.
//

import RagnarokCore
import RagnarokModels
import RagnarokResources
import SwiftUI

struct InventoryItemView: View {
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

struct InventoryItemPreview: View {
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
