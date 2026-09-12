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

private let slotSize: CGFloat = 32
private let iconSize: CGFloat = 24

struct ShortcutBarView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { column in
                let slot = ShortcutSlot(row: row, column: column)
                ShortcutSlotView(slot: slot, shortcut: gameContext.shortcutList.rows[row][column])
            }

            Button {
                gameSession.setShortcutRowShift((row + 1) % gameContext.shortcutList.rows.count)
            } label: {
                Text(verbatim: "\(row + 1)")
            }
            .buttonStyle(.game)
            .frame(width: 24, height: slotSize)
        }
        .padding(4)
        .background {
            GameStripeView()
        }
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
    var slot: ShortcutSlot
    var shortcut: Shortcut

    @Environment(GameContext.self) private var gameContext
    @Environment(ShortcutDragState.self) private var dragState

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(isTargeted ? Color(#colorLiteral(red: 0.7098039216, green: 1, blue: 0.7098039216, alpha: 1)) : Color.white)

            ShortcutIconView(shortcut: shortcut)
                .frame(width: iconSize, height: iconSize)
                .opacity(gameContext.isShortcutAvailable(shortcut) ? 1 : 0.4)

            if let label = gameContext.shortcutLabel(shortcut) {
                Text(verbatim: label)
                    .font(.game(size: 11))
                    .foregroundStyle(Color.gameLabel)
                    .shadow(color: .white, radius: 1)
                    .frame(width: slotSize, height: slotSize, alignment: .bottomTrailing)
            }
        }
        .frame(width: slotSize, height: slotSize)
        .border(Color.gameBoxBorder)
        .shortcutDropTarget(slot)
        .shortcutDragSource(shortcut, from: slot)
    }

    private var isTargeted: Bool {
        dragState.targetSlot == slot
    }
}

struct ShortcutIconView: View {
    var shortcut: Shortcut

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        ZStack {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
            }
        }
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
        .shortcutDragContainer()
        .padding()
        .environment(GameSession.testing)
        .environment(gameContext)
}
