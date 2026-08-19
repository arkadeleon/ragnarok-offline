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

struct ActionControlPadView: View {
    var onAttack: () -> Void
    var onPickup: () -> Void
    var onSkill: (SkillInfo) -> Void

    @Environment(GameContext.self) private var gameContext

    private var shortcutSkills: [SkillInfo] {
        Array(gameContext.skillList.activeSkills.prefix(8))
    }

    var body: some View {
        ZStack {
            RoundActionButton(color: .red.opacity(0.55), diameter: 65, action: onAttack) {
                Text("A")
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }

            RingSectorActionButton(centerAngle: .degrees(45), color: .green.opacity(0.55), action: onPickup) {
                Text("P")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }

            ForEach(0..<8) { index in
                let skill = (index < shortcutSkills.count) ? shortcutSkills[index] : nil

                SkillShortcutButton(centerAngle: .degrees(45 + 40 * Double(index + 1)), skill: skill) {
                    if let skill {
                        onSkill(skill)
                    }
                }
            }
        }
        .frame(width: ringOuterRadius * 2, height: ringOuterRadius * 2)
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
        RingSectorActionButton(centerAngle: centerAngle, color: Color(#colorLiteral(red: 0.7568627451, green: 0.7568627451, blue: 0.7568627451, alpha: 0.3296931004)), action: action) {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
            }
        }
        .disabled(skill == nil)
        .opacity(skill == nil ? 0.6 : 1)
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
    var color: Color
    var action: () -> Void
    @ViewBuilder var content: Content

    private var ringSector: GameRingSector {
        GameRingSector(
            centerAngle: centerAngle,
            sweepAngle: sectorSweepAngle,
            innerRadius: ringInnerRadius,
            outerRadius: ringOuterRadius,
            gap: sectorGap
        )
    }

    var body: some View {
        let contentRadius = (ringInnerRadius + ringOuterRadius) / 2

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

        var bash = SkillInfo()
        bash.skillID = 5
        bash.flag = SkillInfoFlag.attack.rawValue
        bash.level = 5
        bash.spCost = 8
        bash.attackRange = 1
        gameContext.skillList.skills[5] = bash

        var heal = SkillInfo()
        heal.skillID = 28
        heal.flag = SkillInfoFlag.support.rawValue
        heal.level = 10
        heal.spCost = 40
        heal.attackRange = 9
        gameContext.skillList.skills[28] = heal

        return gameContext
    }()

    ZStack(alignment: .bottomTrailing) {
        Color.black

        ActionControlPadView(onAttack: {}, onPickup: {}, onSkill: { _ in })
            .padding(.bottom, 16)
            .padding(.trailing, 16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .environment(gameContext)
}
