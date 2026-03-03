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

    @Environment(GameSession.self) private var gameSession

    @State private var selectedSkillID: Int?

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(skillList.sortedSkills, id: \.skillID) { skill in
                        SkillListRow(skill: skill, isSelected: (selectedSkillID == skill.skillID)) {
                            gameSession.upgradeSkillLevel(skillID: skill.skillID)
                        }
                        .onTapGesture {
                            selectedSkillID = skill.skillID
                        }
                    }
                }
            }
            .frame(height: 220)
            .background(Color.white)
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }
            .overlay(alignment: .trailing) {
                Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
            }

            GameBottomBar()
                .overlay(alignment: .leading) {
                    Text(verbatim: "Skill Points: \(gameSession.playerStatus.skillPoint)")
                        .font(.game())
                        .foregroundStyle(Color.gameProminentLabel)
                        .padding(.leading, 10)
                }
        }
        .frame(width: 300)
    }
}

private struct SkillListRow: View {
    var skill: SkillInfo
    var isSelected: Bool
    var onUpgrade: () -> Void

    @Environment(GameSession.self) private var gameSession

    @State private var iconImage: Resources.Image?

    private var isPassiveSkill: Bool {
        if skill.flag < 0 {
            return skill.spCost == 0
        }
        return skill.flag == SkillInfoFlag.passive.rawValue
    }

    private var isDisabled: Bool {
        skill.level == 0
    }

    private var isUpgradable: Bool {
        skill.isUpgradable && gameSession.playerStatus.skillPoint > 0
    }

    private var skillName: String {
        if let skillName = gameSession.skillInfoTable.localizedSkillName(forSkillID: skill.skillID) {
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
        guard isSelected else {
            return .clear
        }

        if isDisabled {
            return Color(#colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1))
        } else if isPassiveSkill {
            return Color(#colorLiteral(red: 0.4509803922, green: 0.8352941176, blue: 0.9333333333, alpha: 1))
        } else {
            return Color(#colorLiteral(red: 0.4509803922, green: 0.6117647059, blue: 0.9333333333, alpha: 1))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Group {
                    if let iconImage {
                        Image(decorative: iconImage.cgImage, scale: 1)
                            .resizable()
                            .interpolation(.none)
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(#colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)))
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
                Text(verbatim: isPassiveSkill ? "Passive" : "SP: \(skill.spCost)")
                    .font(.game(size: 11))
                    .foregroundStyle(Color.gameLabel)
                    .frame(width: 64, alignment: .trailing)
                    .padding(.trailing, 8)
            } else {
                Spacer(minLength: 0)
            }

            SkillUpgradeButton(action: onUpgrade)
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
            iconImage = try? await gameSession.resourceManager.image(at: path, removesMagentaPixels: true)
        }
    }
}

private struct SkillUpgradeButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(#colorLiteral(red: 0.9686274510, green: 0.9686274510, blue: 0.9686274510, alpha: 1)))

                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color(#colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)), lineWidth: 1)

                SkillUpgradeTrendShape()
                    .stroke(
                        Color(#colorLiteral(red: 0.5843137255, green: 0.7019607843, blue: 0.9607843137, alpha: 1)),
                        style: StrokeStyle(lineWidth: 2.8)
                    )

                SkillUpgradeTrendShape()
                    .stroke(
                        Color(#colorLiteral(red: 0.3215686275, green: 0.4745098039, blue: 0.8392156863, alpha: 1)),
                        style: StrokeStyle(lineWidth: 1.4)
                    )

                Text(verbatim: "Lv UP")
                    .font(.game(size: 6.5, weight: .black))
                    .foregroundStyle(Color.gameLabel)
                    .offset(y: 6.5)
            }
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}

private struct SkillUpgradeTrendShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 5, y: 12.5))
        path.addLine(to: CGPoint(x: 9, y: 8.8))
        path.addLine(to: CGPoint(x: 12, y: 6))
        path.addLine(to: CGPoint(x: 14.8, y: 8.9))
        path.addLine(to: CGPoint(x: 18.2, y: 5.5))

        path.move(to: CGPoint(x: 18.2, y: 5.5))
        path.addLine(to: CGPoint(x: 16.3, y: 5.5))
        path.addLine(to: CGPoint(x: 18.2, y: 7.4))
        path.closeSubpath()

        return path
    }
}

#Preview {
    let gameSession = {
        let gameSession = GameSession.testing
        gameSession.playerStatus.skillPoint = 1
        return gameSession
    }()

    let skillList = {
        let skillList = SkillList()

        var bash = SkillInfo()
        bash.skillID = 5
        bash.flag = SkillInfoFlag.attack.rawValue
        bash.level = 5
        bash.spCost = 8
        bash.attackRange = 1
        bash.isUpgradable = true
        bash.maxLevel = 10
        skillList.skills[5] = bash

        var heal = SkillInfo()
        heal.skillID = 28
        heal.flag = SkillInfoFlag.support.rawValue
        heal.level = 10
        heal.spCost = 40
        heal.attackRange = 9
        heal.isUpgradable = false
        heal.maxLevel = 10
        skillList.skills[28] = heal

        var swordMastery = SkillInfo()
        swordMastery.skillID = 2
        swordMastery.flag = SkillInfoFlag.passive.rawValue
        swordMastery.level = 10
        swordMastery.spCost = 0
        swordMastery.attackRange = 0
        swordMastery.isUpgradable = false
        swordMastery.maxLevel = 10
        skillList.skills[2] = swordMastery

        return skillList
    }()

    SkillListView(skillList: skillList)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(gameSession)
}
