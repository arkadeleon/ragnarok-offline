//
//  SkillListView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/1.
//

import RagnarokConstants
import RagnarokModels
import RagnarokResources
import SwiftUI

struct SkillListView: View {
    var skillList: SkillList
    var onClose: () -> Void = {}

    @Environment(GameContext.self) private var gameContext

    @State private var selectedSkillID: Int?

    var body: some View {
        VStack(spacing: 3) {
            GameWindow {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(skillList.sortedSkills, id: \.skillID) { skill in
                            SkillListRow(skill: skill, isSelected: (selectedSkillID == skill.skillID))
                                .onTapGesture {
                                    selectedSkillID = skill.skillID
                                }
                                .shortcutDragSource(shortcut(for: skill))
                        }
                    }
                }
                .frame(height: 220)
            } titleBar: {
                GameTitleBar(closeAction: onClose)
            } bottomBar: {
                GameBottomBar()
                    .overlay(alignment: .leading) {
                        Text(verbatim: "Skill Points: \(gameContext.playerStatus.skillPoint)")
                            .font(.game())
                            .foregroundStyle(Color.gameProminentLabel)
                            .padding(.leading, 10)
                    }
            }
            .frame(width: 320)

            ShortcutBarView()
        }
        .shortcutDragContainer()
    }

    /// Only a learned, active skill can be put in the shortcut bar.
    private func shortcut(for skill: SkillInfo) -> Shortcut {
        if skill.level > 0 && !skill.isPassiveSkill {
            .skill(skillID: skill.skillID, level: skill.level)
        } else {
            .empty
        }
    }
}

private struct SkillListRow: View {
    var skill: SkillInfo
    var isSelected: Bool

    @Environment(GameContext.self) private var gameContext
    @Environment(\.upgradeSkillLevel) private var upgradeSkillLevel

    @State private var iconImage: Resources.Image?

    private var isDisabled: Bool {
        skill.level == 0
    }

    private var isUpgradable: Bool {
        skill.isUpgradable && gameContext.playerStatus.skillPoint > 0
    }

    private var skillName: String {
        if let skillName = gameContext.skillInfoTable.localizedSkillName(forSkillID: skill.skillID) {
            skillName
        } else if let skillID = SkillID(rawValue: skill.skillID) {
            skillID.stringValue
        } else {
            "Skill \(skill.skillID)"
        }
    }

    private var skillLevel: String {
        if skill.maxLevel > 0 {
            "\(skill.level) / \(skill.maxLevel)"
        } else {
            "\(skill.level)"
        }
    }

    private var skillBackgroundColor: Color {
        if !isSelected {
            .clear
        } else if isDisabled {
            Color(#colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1))
        } else if skill.isPassiveSkill {
            Color(#colorLiteral(red: 0.4509803922, green: 0.8352941176, blue: 0.9333333333, alpha: 1))
        } else {
            Color(#colorLiteral(red: 0.4509803922, green: 0.6117647059, blue: 0.9333333333, alpha: 1))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                ZStack {
                    if let iconImage {
                        Image(decorative: iconImage.cgImage, scale: 1)
                            .resizable()
                            .interpolation(.none)
                    }
                }
                .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(skillName)
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .lineLimit(1)

                    if !isDisabled {
                        Text(verbatim: "Lv: \(skillLevel)")
                            .font(.game(size: 11))
                            .foregroundStyle(Color.gameProminentLabel)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(isDisabled ? 0.5 : 1)
            .padding(.leading, 15)
            .padding(.trailing, 8)

            if !isDisabled {
                Text(verbatim: skill.isPassiveSkill ? "Passive" : "SP: \(skill.spCost)")
                    .font(.game(size: 11))
                    .foregroundStyle(Color.gameLabel)
                    .frame(width: 64, alignment: .trailing)
                    .padding(.trailing, 8)
            } else {
                Spacer(minLength: 0)
            }

            SkillUpgradeButton {
                upgradeSkillLevel?(skillID: skill.skillID)
            }
            .frame(width: 30, height: 24)
            .opacity(isUpgradable ? 1 : 0)
            .disabled(!isUpgradable)
            .padding(.trailing, 2)
        }
        .frame(height: 36)
        .background(skillBackgroundColor)
        .contentShape(Rectangle())
        .task(id: skill.skillID) {
            guard let skillID = SkillID(rawValue: skill.skillID) else {
                return
            }

            let path = ResourcePath.generateSkillIconImagePath(skillAegisName: skillID.stringValue)
            iconImage = try? await gameContext.resourceManager.image(at: path, removesMagentaPixels: true)
        }
    }
}

private struct SkillUpgradeButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                SkillUpgradeTrendShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(#colorLiteral(red: 0.4392156863, green: 0.5490196078, blue: 0.8156862745, alpha: 1)),
                                Color(#colorLiteral(red: 0.3764705882, green: 0.5019607843, blue: 0.7843137255, alpha: 1)),
                                Color(#colorLiteral(red: 0.6588235294, green: 0.7215686275, blue: 0.8784313725, alpha: 1)),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(verbatim: "Lv UP")
                    .font(.game(size: 6.5, weight: .black))
                    .tracking(-0.15)
                    .foregroundStyle(Color.gameLabel)
                    .offset(y: 5.5)
            }
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.game)
        .frame(width: 24, height: 24)
    }
}

private struct SkillUpgradeTrendShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 3, y: 13))
        path.addLine(to: CGPoint(x: 10.5, y: 5.5))
        path.addQuadCurve(to: CGPoint(x: 11.5, y: 5.5), control: CGPoint(x: 11, y: 5))
        path.addLine(to: CGPoint(x: 15.5, y: 9.5))
        path.addLine(to: CGPoint(x: 18.875, y: 6.125))
        path.addLine(to: CGPoint(x: 17, y: 4.25))
        path.addLine(to: CGPoint(x: 22, y: 4.25))
        path.addLine(to: CGPoint(x: 22, y: 9.25))
        path.addLine(to: CGPoint(x: 20.125, y: 7.375))
        path.addLine(to: CGPoint(x: 16.2, y: 11.3))
        path.addQuadCurve(to: CGPoint(x: 14.8, y: 11.3), control: CGPoint(x: 15.5, y: 12))
        path.addLine(to: CGPoint(x: 11, y: 7.5))
        path.addLine(to: CGPoint(x: 8.5, y: 13))
        path.closeSubpath()
        return path.applying(CGAffineTransform(scaleX: rect.width / 24, y: rect.height / 24))
    }
}

#Preview {
    let gameContext = {
        let gameContext = GameContext.testing

        gameContext.playerStatus.skillPoint = 1

        var bash = SkillInfo()
        bash.skillID = 5
        bash.flag = SkillInfoFlag.attack.rawValue
        bash.level = 5
        bash.spCost = 8
        bash.attackRange = 1
        bash.isUpgradable = true
        bash.maxLevel = 10
        gameContext.skillList.skills[5] = bash

        var heal = SkillInfo()
        heal.skillID = 28
        heal.flag = SkillInfoFlag.support.rawValue
        heal.level = 10
        heal.spCost = 40
        heal.attackRange = 9
        heal.isUpgradable = false
        heal.maxLevel = 10
        gameContext.skillList.skills[28] = heal

        var swordMastery = SkillInfo()
        swordMastery.skillID = 2
        swordMastery.flag = SkillInfoFlag.passive.rawValue
        swordMastery.level = 10
        swordMastery.spCost = 0
        swordMastery.attackRange = 0
        swordMastery.isUpgradable = false
        swordMastery.maxLevel = 10
        gameContext.skillList.skills[2] = swordMastery

        return gameContext
    }()

    SkillListView(skillList: gameContext.skillList)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
        .environment(gameContext)
}
