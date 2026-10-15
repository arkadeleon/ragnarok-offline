//
//  ActionBarView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/11.
//

import RagnarokModels
import SwiftUI

struct ActionBarView: View {
    var selectedTargetObjectType: MapObjectType?
    var onTargetAction: () -> Void
    var onSelectNextTarget: () -> Void
    var onPickup: () -> Void
    var onSit: () -> Void
    var onShortcut: (Shortcut) -> Void

    @Environment(GameSession.self) private var gameSession
    @Environment(GameContext.self) private var gameContext

    @State private var currentRow = 0

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 6) {
                ActionRoundButton(
                    color: Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)),
                    action: {
                        gameSession.interactionMode = gameSession.interactionMode == .direct ? .select : .direct
                    }
                ) {
                    Image(systemName: gameSession.interactionMode == .direct ? "hand.tap" : "hand.point.up.left")
                        .font(.game(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                ActionRoundButton(
                    color: Color(#colorLiteral(red: 0.8877201569, green: 0.7630142746, blue: 0.3606613333, alpha: 0.55)),
                    action: onSelectNextTarget
                ) {
                    Image(systemName: "scope")
                        .font(.game(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            HStack(spacing: 6) {
                ActionRoundButton(
                    color: Color(#colorLiteral(red: 0.2155968627, green: 0.3285380392, blue: 0.5614792157, alpha: 0.55)),
                    action: onPickup
                ) {
                    Image(systemName: "hand.wave")
                        .font(.game(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                ActionRoundButton(
                    color: Color(#colorLiteral(red: 0.2328621177, green: 0.543450353, blue: 0.3646268235, alpha: 0.55)),
                    action: onSit
                ) {
                    Image(systemName: "figure.seated.side")
                        .font(.game(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                ActionRoundButton(
                    color: Color(#colorLiteral(red: 0.6283159216, green: 0.2047865098, blue: 0.1977276863, alpha: 0.55)),
                    action: onTargetAction
                ) {
                    if selectedTargetObjectType == .npc {
                        GameTalkIcon()
                            .frame(width: 24, height: 24)
                    } else {
                        GameSwordIcon()
                            .frame(width: 24, height: 24)
                    }
                }
            }

            HStack(spacing: 0) {
                Button(action: turnRow) {
                    ZStack {
                        Circle()
                            .fill(Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)))

                        Text(verbatim: "\(row + 1)")
                            .font(.game(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 24, height: 24)
                    .padding(6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    ForEach(0..<8, id: \.self) { column in
                        let shortcut = gameContext.shortcutList.rows[row][column]

                        ActionSlotButton(shortcut: shortcut) {
                            onShortcut(shortcut)
                        }
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .circular))
            }
        }
    }

    private var row: Int {
        let nonEmptyRows = gameContext.shortcutList.nonEmptyRows
        if nonEmptyRows.contains(currentRow) {
            return currentRow
        }
        return nonEmptyRows.first ?? currentRow
    }

    private func turnRow() {
        let nonEmptyRows = gameContext.shortcutList.nonEmptyRows
        guard nonEmptyRows.count > 1 else {
            return
        }

        currentRow = nonEmptyRows.first(where: { $0 > row }) ?? nonEmptyRows[0]
    }
}

private struct ActionRoundButton<Content>: View where Content: View {
    var color: Color
    var action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)

                content
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ActionSlotButton: View {
    var shortcut: Shortcut
    var action: () -> Void

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)))

                ShortcutIconView(shortcut: shortcut)
                    .frame(width: 24, height: 24)
                    .opacity(gameContext.isShortcutAvailable(shortcut) ? 1 : 0.4)
                    .overlay {
                        if let cooldown = gameContext.skillCooldown(for: shortcut) {
                            SkillCooldownView(cooldown: cooldown)
                        }
                    }

                if let label = gameContext.shortcutLabel(shortcut) {
                    Text(verbatim: label)
                        .font(.game(size: 11))
                        .foregroundStyle(Color.white)
                        .shadow(color: .black, radius: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(2)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 28, idealWidth: 36, maxWidth: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Regular") {
    let gameSession = {
        let gameSession = GameSession(resourceManager: .testing)
        let gameContext = gameSession.context

        var redPotion = InventoryItem()
        redPotion.index = 0
        redPotion.itemID = 501
        redPotion.type = .healing
        redPotion.amount = 12
        gameContext.inventory.append(item: redPotion)

        var shortcutList = ShortcutList()
        for (column, skillID) in [5, 7, 10, 16, 17, 18, 19].enumerated() {
            shortcutList.setShortcut(.skill(skillID: skillID, level: 1), atRow: 0, column: column)
        }
        shortcutList.setShortcut(.item(itemID: 501), atRow: 0, column: 7)
        shortcutList.setShortcut(.skill(skillID: 28, level: 10), atRow: 2, column: 0)
        gameContext.shortcutList = shortcutList

        return gameSession
    }()

    ActionBarView(selectedTargetObjectType: nil, onTargetAction: {}, onSelectNextTarget: {}, onPickup: {}, onSit: {}, onShortcut: { _ in })
        .padding()
        .frame(width: 480, height: 360, alignment: .bottomTrailing)
        .environment(gameSession)
        .environment(gameSession.context)
}

#Preview("Minimal") {
    let gameSession = {
        let gameSession = GameSession(resourceManager: .testing)
        let gameContext = gameSession.context

        var shortcutList = ShortcutList()
        for (column, skillID) in [5, 7, 10, 16, 17, 18, 19].enumerated() {
            shortcutList.setShortcut(.skill(skillID: skillID, level: 1), atRow: 0, column: column)
        }
        gameContext.shortcutList = shortcutList

        return gameSession
    }()

    ActionBarView(selectedTargetObjectType: nil, onTargetAction: {}, onSelectNextTarget: {}, onPickup: {}, onSit: {}, onShortcut: { _ in })
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical)
        .frame(width: 360)
        .environment(gameSession)
        .environment(gameSession.context)
}
