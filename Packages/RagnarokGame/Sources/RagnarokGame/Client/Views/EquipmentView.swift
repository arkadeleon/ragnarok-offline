//
//  EquipmentView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/2/2.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
import SwiftUI

struct EquipmentView: View {
    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    EquipmentLeftSlotRow(label: "head", location: .head_top)
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "head", location: .head_mid)
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "R-hand", location: .right_hand)
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "robe", location: .garment)
                    EquipmentSlotDivider()
                    EquipmentLeftSlotRow(label: "acc.1", location: .right_accessory)
                }
                .frame(width: 120)

                EquipmentCharacterView()

                VStack(spacing: 0) {
                    EquipmentRightSlotRow(label: "head", location: .head_low)
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "body", location: .armor)
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "L-hand", location: .left_hand)
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "shoes", location: .shoes)
                    EquipmentSlotDivider()
                    EquipmentRightSlotRow(label: "acc.2", location: .left_accessory)
                }
                .frame(width: 120)
            }
            .frame(height: 134)
            .background(Color.white)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }

            GameBottomBar()
        }
        .frame(width: 320)
    }
}

private struct EquipmentCharacterView: View {
    var body: some View {
        ZStack {
            EquipmentCharacterBackground()
            EquipmentCharacterShadow()
                .offset(y: 50)
        }
    }
}

private struct EquipmentCharacterBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let stripeCount = max(0, Int((geometry.size.height + 2) / 4))

            VStack(spacing: 2) {
                ForEach(0..<stripeCount, id: \.self) { _ in
                    Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)).frame(height: 2)
                }
            }
        }
    }
}

private struct EquipmentCharacterShadow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color(#colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)).opacity(0.9), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1)).opacity(0.55), location: 0.55),
                        .init(color: Color(#colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1)).opacity(0.0), location: 1)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 38
                )
            )
            .frame(width: 38, height: 24)
            .blendMode(.multiply)
    }
}

private struct EquipmentLeftSlotRow: View {
    var label: String
    var location: EquipPositions

    var body: some View {
        HStack(spacing: 4) {
            EquipmentSlotImage(location: location)
            EquipmentSlotLabel(label: label, location: location, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .frame(height: 26)
    }
}

private struct EquipmentRightSlotRow: View {
    var label: String
    var location: EquipPositions

    var body: some View {
        HStack(spacing: 4) {
            EquipmentSlotLabel(label: label, location: location, alignment: .trailing)
            EquipmentSlotImage(location: location)
        }
        .padding(.horizontal, 4)
        .frame(height: 26)
    }
}

private struct EquipmentSlotLabel: View {
    var label: String
    var location: EquipPositions
    var alignment: HorizontalAlignment

    @Environment(GameSession.self) private var gameSession

    private var itemName: String? {
        guard let item = gameSession.inventory.item(equippedAt: location) else {
            return nil
        }
        return gameSession.itemInfoTable.localizedIdentifiedItemName(forItemID: item.itemID)
    }

    var body: some View {
        ZStack {
            Text(label)
                .font(.game(size: 10))
                .foregroundStyle(Color(#colorLiteral(red: 0.8823529412, green: 0.8941176471, blue: 0.9137254902, alpha: 1)))
                .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
                .offset(y: 5)

            if let itemName {
                Text(itemName)
                    .font(.game(size: 10))
                    .foregroundStyle(Color(#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)))
                    .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
                    .lineLimit(2)
            }
        }
    }
}

private struct EquipmentSlotImage: View {
    var location: EquipPositions

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: CGImage?

    private var equippedItem: InventoryItem? {
        gameSession.inventory.item(equippedAt: location)
    }

    var body: some View {
        ZStack {
            EquipmentSlotShadow()
                .offset(y: 5)

            if let iconImage {
                Image(decorative: iconImage, scale: 1)
            }
        }
        .frame(width: 26, height: 26)
        .task(id: equippedItem?.itemID) {
            guard let equippedItem else {
                iconImage = nil
                return
            }
            let resourceManager = gameSession.resourceManager
            let scriptContext = await resourceManager.scriptContext()
            if let path = ResourcePath.generateItemIconImagePath(itemID: equippedItem.itemID, scriptContext: scriptContext) {
                iconImage = try? await resourceManager.image(at: path, removesMagentaPixels: true)
            }
        }
    }
}

private struct EquipmentSlotShadow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color(#colorLiteral(red: 0.7294117647, green: 0.7725490196, blue: 0.8549019608, alpha: 1)).opacity(0.9), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.7176470588, green: 0.7607843137, blue: 0.8470588235, alpha: 1)).opacity(0.55), location: 0.55),
                        .init(color: Color(#colorLiteral(red: 0.7450980392, green: 0.7843137255, blue: 0.8588235294, alpha: 1)).opacity(0.0), location: 1)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 18
                )
            )
            .frame(width: 18, height: 9)
    }
}

private struct EquipmentSlotDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gameBoxBorder)
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview {
    EquipmentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
