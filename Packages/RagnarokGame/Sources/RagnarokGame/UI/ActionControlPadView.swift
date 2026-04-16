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

struct ActionControlPadView: View {
    var onAttack: () -> Void
    var onPickup: () -> Void
    var onTalk: () -> Void
    var onSkill: (SkillInfo) -> Void

    @Environment(GameSession.self) private var gameSession

    private var shortcutSkills: [SkillInfo] {
        Array(gameSession.skillList.activeSkills.prefix(5))
    }

    var body: some View {
        ZStack {
            RoundActionButton(color: .red, diameter: 55, action: onAttack) {
                Text("A")
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }

            ForEach(0..<5) { index in
                let skill = (index < shortcutSkills.count) ? shortcutSkills[index] : nil

                SkillShortcutButton(skill: skill) {
                    if let skill {
                        onSkill(skill)
                    }
                }
                .offset(
                    x: -75 * sin(radians(135 - CGFloat(index) * 45)),
                    y: -75 * cos(radians(135 - CGFloat(index) * 45))
                )
            }

            RoundActionButton(color: .green, diameter: 35, action: onPickup) {
                Text("P")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            .offset(x: -65 * sin(radians(-110)), y: -65 * cos(radians(-110)))

            RoundActionButton(color: .blue, diameter: 35, action: onTalk) {
                Text("T")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            .offset(x: -65 * sin(radians(-160)), y: -65 * cos(radians(-160)))
        }
        .frame(width: 180, height: 180)
        .offset(x: 10, y: 10)
    }
}

private struct SkillShortcutButton: View {
    var skill: SkillInfo?
    var action: () -> Void

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: Resources.Image?

    var body: some View {
        RoundActionButton(color: .orange, diameter: 45, action: action) {
            if let iconImage {
                Image(decorative: iconImage.cgImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .padding(6)
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
            iconImage = try? await gameSession.resourceManager.image(at: path, removesMagentaPixels: true)
        }
    }
}

struct RoundActionButton<Content: View>: View {
    var color: Color
    var diameter: CGFloat
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.75))
                    .frame(width: diameter, height: diameter)
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)

                content()
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession(resourceManager: .testing)

        var bash = SkillInfo()
        bash.skillID = 5
        bash.flag = SkillInfoFlag.attack.rawValue
        bash.level = 5
        bash.spCost = 8
        bash.attackRange = 1
        gameSession.skillList.skills[5] = bash

        var heal = SkillInfo()
        heal.skillID = 28
        heal.flag = SkillInfoFlag.support.rawValue
        heal.level = 10
        heal.spCost = 40
        heal.attackRange = 9
        gameSession.skillList.skills[28] = heal

        return gameSession
    }()

    ZStack(alignment: .bottomTrailing) {
        Color.black.opacity(0.2)

        ActionControlPadView(onAttack: {}, onPickup: {}, onTalk: {}, onSkill: { _ in })
            .padding(.bottom, 16)
            .padding(.trailing, 16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .environment(gameSession)
}
