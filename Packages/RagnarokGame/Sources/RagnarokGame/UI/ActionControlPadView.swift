//
//  ActionControlPadView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/4.
//

import RagnarokModels
import SwiftUI

private let ringInnerRadius: CGFloat = 40
private let ringOuterRadius: CGFloat = 88
private let sectorSweepAngle: Angle = .degrees(360 / 9)
private let sectorGap: CGFloat = 4

private let shortcutsPerRow = 8

struct ActionControlPadView: View {
    var onAttack: () -> Void
    var onPickup: () -> Void
    var onShortcut: (Shortcut) -> Void

    @Environment(GameContext.self) private var gameContext

    @State private var currentRow = 0
    @State private var dialAngle: Angle = .zero

    var body: some View {
        ZStack {
            ZStack {
                ForEach(0..<shortcutsPerRow, id: \.self) { column in
                    let shortcut = gameContext.shortcutList.rows[row][column]

                    ShortcutActionButton(centerAngle: .degrees(45 + 40 * Double(column + 1)), shortcut: shortcut) {
                        onShortcut(shortcut)
                    }
                }
            }
            .rotationEffect(dialAngle)

            RingSectorActionButton(
                centerAngle: .degrees(45),
                innerRadius: ringInnerRadius,
                outerRadius: (ringInnerRadius + ringOuterRadius) / 2 - sectorGap / 2,
                color: .green.opacity(0.55),
                action: onPickup
            ) {
                Image(systemName: "hand.wave")
                    .font(.game(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            RingSectorActionButton(
                centerAngle: .degrees(45),
                innerRadius: (ringInnerRadius + ringOuterRadius) / 2 + sectorGap / 2,
                outerRadius: ringOuterRadius,
                color: .blue.opacity(0.55),
                action: turnDial
            ) {
                Image(systemName: "arrow.clockwise")
                    .font(.game(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            RoundActionButton(
                color: .red.opacity(0.55),
                diameter: (ringInnerRadius - sectorGap) * 2,
                action: onAttack
            ) {
                GameSwordIcon()
                    .frame(width: 40, height: 40)
            }
        }
        .frame(width: ringOuterRadius * 2, height: ringOuterRadius * 2)
    }

    private var row: Int {
        let nonEmptyRows = gameContext.shortcutList.nonEmptyRows
        if nonEmptyRows.contains(currentRow) {
            return currentRow
        }
        return nonEmptyRows.first ?? currentRow
    }

    private func turnDial() {
        let nonEmptyRows = gameContext.shortcutList.nonEmptyRows
        guard nonEmptyRows.count > 1 else {
            return
        }

        let nextRow = nonEmptyRows.first(where: { $0 > row }) ?? nonEmptyRows[0]

        withAnimation(.easeIn(duration: 0.15)) {
            dialAngle = sectorSweepAngle
        } completion: {
            currentRow = nextRow

            withAnimation(.easeOut(duration: 0.35)) {
                dialAngle = .zero
            }
        }
    }
}

private struct RoundActionButton<Content>: View where Content: View {
    var color: Color
    var diameter: CGFloat
    var action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: diameter, height: diameter)

                content
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private struct ShortcutActionButton: View {
    var centerAngle: Angle
    var shortcut: Shortcut
    var action: () -> Void

    @Environment(GameContext.self) private var gameContext

    var body: some View {
        RingSectorActionButton(
            centerAngle: centerAngle,
            innerRadius: ringInnerRadius,
            outerRadius: ringOuterRadius,
            color: Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)),
            action: action
        ) {
            ZStack {
                ShortcutIconView(shortcut: shortcut)
                    .opacity(gameContext.isShortcutAvailable(shortcut) ? 1 : 0.4)
                    .id(shortcut)
                    .transition(.opacity)

                if let label = gameContext.shortcutLabel(shortcut) {
                    Text(verbatim: label)
                        .font(.game(size: 11))
                        .foregroundStyle(Color.white)
                        .shadow(color: .black, radius: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: shortcut)
    }
}

private struct RingSectorActionButton<Content>: View where Content: View {
    var centerAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    var color: Color
    var action: () -> Void
    @ViewBuilder var content: Content

    private var ringSector: GameRingSector {
        GameRingSector(
            centerAngle: centerAngle,
            sweepAngle: sectorSweepAngle,
            innerRadius: innerRadius,
            outerRadius: outerRadius,
            gap: sectorGap
        )
    }

    var body: some View {
        let contentRadius = (innerRadius + outerRadius) / 2

        Button(action: action) {
            ZStack {
                ringSector
                    .fill(color)

                content
                    .frame(width: 28, height: 28)
                    .offset(
                        x: contentRadius * cos(centerAngle.radians),
                        y: contentRadius * sin(centerAngle.radians)
                    )
            }
            .frame(width: ringOuterRadius * 2, height: ringOuterRadius * 2)
            .contentShape(ringSector)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let gameContext = {
        let gameContext = GameContext(resourceManager: .testing)

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

        return gameContext
    }()

    ActionControlPadView(onAttack: {}, onPickup: {}, onShortcut: { _ in })
        .padding()
        .background(Color.black)
        .environment(gameContext)
}
