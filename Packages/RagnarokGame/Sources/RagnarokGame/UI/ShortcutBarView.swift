//
//  ShortcutBarView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/10.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
import SwiftUI

private let slotSize: CGFloat = 28
private let iconSize: CGFloat = 24

struct ShortcutBarView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<8, id: \.self) { column in
                ShortcutSlotView(shortcut: gameContext.shortcutList.rows[row][column])
            }

            Button {
                gameSession.setShortcutRowShift(row)
            } label: {
                Text(verbatim: "\(row + 1)")
            }
            .buttonStyle(.game)
            .frame(width: slotSize, height: slotSize)
        }
        .padding(6)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Color.gameBoxBorder, lineWidth: 1 / displayScale)
        }
    }

    private var row: Int {
        let rows = gameContext.shortcutList.rows
        var row = gameContext.shortcutList.rowShift
        row = max(row, 0)
        row = min(row, rows.count - 1)
        return row
    }
}

private struct ShortcutSlotView: View {
    var shortcut: Shortcut

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gameSecondaryBoxBackground)

            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: iconSize, height: iconSize)
            }

            if let label {
                Text(verbatim: label)
                    .font(.game(size: 11))
                    .foregroundStyle(Color.gameLabel)
                    .shadow(color: .white, radius: 1)
                    .frame(width: slotSize, height: slotSize, alignment: .bottomTrailing)
            }
        }
        .frame(width: slotSize, height: slotSize)
        .opacity(isAvailable ? 1 : 0.4)
        .task(id: shortcut) {
            switch shortcut {
            case .empty:
                iconImage = nil
            case .item(let itemID):
                iconImage = try? await gameContext.resourceManager.itemIconImage(forItemID: itemID)
            case .skill(let skillID, _):
                guard let skillID = SkillID(rawValue: skillID) else {
                    iconImage = nil
                    return
                }

                let path = ResourcePath.generateSkillIconImagePath(skillAegisName: skillID.stringValue)
                iconImage = try? await gameContext.resourceManager.image(at: path, removesMagentaPixels: true)
            }
        }
    }

    /// An item which is no longer in the inventory is dimmed.
    private var isAvailable: Bool {
        switch shortcut {
        case .empty, .skill:
            true
        case .item(let itemID):
            gameContext.inventory.items.values.contains(where: { $0.itemID == itemID })
        }
    }

    private var label: String? {
        switch shortcut {
        case .empty:
            return nil
        case .item(let itemID):
            if let inventoryItem = gameContext.inventory.items.values.first(where: { $0.itemID == itemID }) {
                return "\(inventoryItem.amount)"
            } else {
                return nil
            }
        case .skill(_, let level):
            return "\(level)"
        }
    }
}

#Preview {
    let gameContext = {
        let gameContext = GameContext.testing

        var redPotion = InventoryItem()
        redPotion.index = 0
        redPotion.itemID = 501
        redPotion.type = .healing
        redPotion.amount = 12
        gameContext.inventory.append(item: redPotion)

        var shortcutList = ShortcutList()
        shortcutList.setShortcut(.skill(skillID: 5, level: 5), atRow: 0, column: 0)
        shortcutList.setShortcut(.item(itemID: 501), atRow: 0, column: 1)
        shortcutList.setShortcut(.item(itemID: 502), atRow: 0, column: 2)
        gameContext.shortcutList = shortcutList

        return gameContext
    }()

    ShortcutBarView()
        .padding()
        .environment(GameSession.testing)
        .environment(gameContext)
}
