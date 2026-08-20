//
//  ActionControlPadView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/4.
//

import RagnarokConstants
import RagnarokCore
import RagnarokModels
import RagnarokResources
import SwiftUI

private let ringInnerRadius: CGFloat = 40
private let ringOuterRadius: CGFloat = 88
private let sectorSweepAngle: Angle = .degrees(360 / 9)
private let sectorGap: CGFloat = 4

private let shortcutsPerPage = 8
private let shortcutPageCount = 2

struct ActionControlPadView: View {
    var onAttack: () -> Void
    var onPickup: () -> Void
    var onSkill: (SkillInfo) -> Void

    @Environment(GameContext.self) private var gameContext

    @State private var currentPage = 0
    @State private var dialAngle: Angle = .zero

    /// The shortcuts on the current page.
    private var shortcutSkills: [SkillInfo] {
        let activeSkills = gameContext.skillList.activeSkills
        let startIndex = currentPage * shortcutsPerPage
        guard startIndex < activeSkills.count else {
            return []
        }
        let endIndex = min(startIndex + shortcutsPerPage, activeSkills.count)
        return Array(activeSkills[startIndex..<endIndex])
    }

    var body: some View {
        ZStack {
            ZStack {
                ForEach(0..<shortcutsPerPage, id: \.self) { index in
                    let skill = (index < shortcutSkills.count) ? shortcutSkills[index] : nil

                    SkillShortcutButton(centerAngle: .degrees(45 + 40 * Double(index + 1)), skill: skill) {
                        if let skill {
                            onSkill(skill)
                        }
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

    private func turnDial() {
        withAnimation(.easeIn(duration: 0.15)) {
            dialAngle = sectorSweepAngle
        } completion: {
            currentPage = (currentPage + 1) % shortcutPageCount

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

private struct SkillShortcutButton: View {
    var centerAngle: Angle
    var skill: SkillInfo?
    var action: () -> Void

    @Environment(GameContext.self) private var gameContext

    @State private var iconImage: Resources.Image?

    var body: some View {
        let iconImageKey = iconImage.map({ ObjectIdentifier($0) })

        RingSectorActionButton(
            centerAngle: centerAngle,
            innerRadius: ringInnerRadius,
            outerRadius: ringOuterRadius,
            color: Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)),
            action: action
        ) {
            ZStack {
                if let iconImage {
                    Image(decorative: iconImage.cgImage, scale: 1)
                        .resizable()
                        .interpolation(.none)
                        .transition(.opacity)
                        .id(iconImageKey)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: iconImageKey)
        }
        .animation(.easeInOut(duration: 0.2), value: skill == nil)
        .task(id: skill?.skillID) {
            guard let skill, let skillID = SkillID(rawValue: skill.skillID) else {
                iconImage = nil
                return
            }

            let path = ResourcePath.generateSkillIconImagePath(skillAegisName: skillID.stringValue)
            iconImage = try? await gameContext.resourceManager.image(at: path, removesMagentaPixels: true)
        }
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

        for skillID in [5, 7, 10, 16, 17, 18, 19, 20, 21, 25, 26, 28] {
            var skill = SkillInfo()
            skill.skillID = skillID
            skill.flag = SkillInfoFlag.attack.rawValue
            skill.level = 1
            skill.attackRange = 1
            gameContext.skillList.skills[skillID] = skill
        }

        return gameContext
    }()

    ActionControlPadView(onAttack: {}, onPickup: {}, onSkill: { _ in })
        .padding()
        .background(Color.black)
        .environment(gameContext)
}
