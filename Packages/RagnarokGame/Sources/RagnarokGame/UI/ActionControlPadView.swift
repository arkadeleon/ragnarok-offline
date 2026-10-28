//
//  ActionControlPadView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/4.
//

import RagnarokModels
import SwiftUI

private let ringInnerRadius: CGFloat = 40
private let ringOuterRadius: CGFloat = 84
private let sectorSweepAngle: Angle = .degrees(360 / 9)
private let sectorGap: CGFloat = 4
private let supplementaryRingWidth: CGFloat = 28

private let shortcutsPerRow = 8

struct ActionControlPadView: View {
    var selectedTargetType: MapObjectType?
    var onTargetAction: () -> Void
    var onSelectNextTarget: () -> Void
    var onPickup: () -> Void
    var onSit: () -> Void
    var onShortcut: (Shortcut) -> Void

    @Environment(PlaySession.self) private var playSession

    @State private var currentRow = 0
    @State private var dialAngle: Angle = .zero

    var body: some View {
        ZStack {
            ZStack {
                ForEach(0..<shortcutsPerRow, id: \.self) { column in
                    let shortcut = playSession.shortcutList.rows[row][column]

                    ShortcutActionButton(centerAngle: .degrees(45 + 40 * Double(column + 1)), shortcut: shortcut) {
                        onShortcut(shortcut)
                    }
                }
            }
            .rotationEffect(dialAngle)

            RingSectorActionButton(
                centerAngle: .degrees(45),
                innerRadius: ringInnerRadius,
                outerRadius: ringOuterRadius,
                color: Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)),
                action: turnDial
            ) {
                Image(systemName: "arrow.clockwise")
                    .font(.game(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)), radius: 0, x: 1)
                    .shadow(color: Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)), radius: 0, x: -1)
                    .shadow(color: Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)), radius: 0, y: 1)
                    .shadow(color: Color(#colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.1098039216, alpha: 1)), radius: 0, y: -1)
            }

            RoundActionButton(
                color: .red.opacity(0.55),
                diameter: (ringInnerRadius - sectorGap) * 2,
                action: onTargetAction
            ) {
                if selectedTargetType == .npc {
                    GameTalkIcon()
                        .frame(width: 34, height: 34)
                } else {
                    GameSwordIcon()
                        .frame(width: 40, height: 40)
                }
            }

            RingSectorActionButton(
                centerAngle: .degrees(165),
                innerRadius: ringOuterRadius + sectorGap,
                outerRadius: ringOuterRadius + sectorGap + supplementaryRingWidth,
                color: Color(#colorLiteral(red: 0.8877201569, green: 0.7630142746, blue: 0.3606613333, alpha: 0.55)),
                action: {}
            ) {
            }

            RingSectorActionButton(
                centerAngle: .degrees(205),
                innerRadius: ringOuterRadius + sectorGap,
                outerRadius: ringOuterRadius + sectorGap + supplementaryRingWidth,
                color: Color(#colorLiteral(red: 0.2328621177, green: 0.543450353, blue: 0.3646268235, alpha: 0.55)),
                action: onSit
            ) {
                Image(systemName: "figure.seated.side")
                    .font(.game(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            RingSectorActionButton(
                centerAngle: .degrees(245),
                innerRadius: ringOuterRadius + sectorGap,
                outerRadius: ringOuterRadius + sectorGap + supplementaryRingWidth,
                color: Color(#colorLiteral(red: 0.2155968627, green: 0.3285380392, blue: 0.5614792157, alpha: 0.55)),
                action: onPickup
            ) {
                Image(systemName: "hand.wave")
                    .font(.game(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            RingSectorActionButton(
                centerAngle: .degrees(285),
                innerRadius: ringOuterRadius + sectorGap,
                outerRadius: ringOuterRadius + sectorGap + supplementaryRingWidth,
                color: Color(#colorLiteral(red: 0.6283159216, green: 0.2047865098, blue: 0.1977276863, alpha: 0.55)),
                action: onSelectNextTarget
            ) {
                Image(systemName: "scope")
                    .font(.game(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: ringOuterRadius * 2, height: ringOuterRadius * 2)
        .padding([.leading, .top], sectorGap + supplementaryRingWidth)
    }

    private var row: Int {
        let nonEmptyRows = playSession.shortcutList.nonEmptyRows
        if nonEmptyRows.contains(currentRow) {
            return currentRow
        }
        return nonEmptyRows.first ?? currentRow
    }

    private func turnDial() {
        let nonEmptyRows = playSession.shortcutList.nonEmptyRows
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

    @Environment(PlaySession.self) private var playSession

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
                    .opacity(playSession.isShortcutAvailable(shortcut) ? 1 : 0.4)
                    .id(shortcut)
                    .transition(.opacity)

                if let label = playSession.shortcutLabel(shortcut) {
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
            .frame(width: outerRadius * 2, height: outerRadius * 2)
            .contentShape(ringSector)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let gameContext = GameContext(resourceManager: .testing)
    let playSession = {
        let playSession = PlaySession(context: gameContext)

        var redPotion = InventoryItem()
        redPotion.index = 0
        redPotion.itemID = 501
        redPotion.type = .healing
        redPotion.amount = 12
        playSession.inventory.append(item: redPotion)

        var shortcutList = ShortcutList()
        for (column, skillID) in [5, 7, 10, 16, 17, 18, 19].enumerated() {
            shortcutList.setShortcut(.skill(skillID: skillID, level: 1), atRow: 0, column: column)
        }
        shortcutList.setShortcut(.item(itemID: 501), atRow: 0, column: 7)
        shortcutList.setShortcut(.skill(skillID: 28, level: 10), atRow: 2, column: 0)
        playSession.shortcutList = shortcutList

        return playSession
    }()

    ActionControlPadView(selectedTargetType: nil, onTargetAction: {}, onSelectNextTarget: {}, onPickup: {}, onSit: {}, onShortcut: { _ in })
        .padding()
        .background(Color.black)
        .environment(gameContext)
        .environment(playSession)
}
