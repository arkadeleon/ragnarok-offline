//
//  BasicInfoView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/6.
//

import RagnarokConstants
import RagnarokModels
import SwiftUI

struct BasicInfoView: View {
    var character: CharacterInfo
    var status: CharacterStatus

    var body: some View {
        GameWindow {
            VStack(alignment: .leading, spacing: 0) {
                Text(character.name)
                    .gameText()
                    .padding(.leading, 10)

                Text(JobID(rawValue: character.job)?.stringValue ?? "")
                    .gameText()
                    .padding(.leading, 10)

                Spacer()
                    .frame(height: 4)

                BasicInfoHPSPBar(
                    label: "HP",
                    current: Int(status.hp),
                    max: Int(status.maxHp),
                    topColor: Color(#colorLiteral(red: 0.50, green: 0.90, blue: 0.55, alpha: 1)),
                    bottomColor: Color(#colorLiteral(red: 0.75, green: 1.0, blue: 0.80, alpha: 1))
                )

                Spacer()
                    .frame(height: 4)

                BasicInfoHPSPBar(
                    label: "SP",
                    current: Int(status.sp),
                    max: Int(status.maxSp),
                    topColor: Color(#colorLiteral(red: 0.40, green: 0.65, blue: 0.95, alpha: 1)),
                    bottomColor: Color(#colorLiteral(red: 0.65, green: 0.85, blue: 1.0, alpha: 1))
                )

                Spacer()
                    .frame(height: 4)

                VStack(spacing: 0) {
                    BasicInfoExpBar(
                        label: "Base Lv. \(status.baseLevel)",
                        fraction: baseExp
                    )

                    BasicInfoExpBar(
                        label: "Job Lv.  \(status.jobLevel)",
                        fraction: jobExp
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color(#colorLiteral(red: 0.8980392157, green: 0.9058823529, blue: 0.9176470588, alpha: 1))))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
            }
            .padding(.top, 3)
        } bottomBar: {
            GameBottomBar()
                .overlay(alignment: .trailing) {
                    Text(verbatim: "Weight: \(status.weight)/\(status.maxWeight)  Zeny: \(status.zeny)")
                        .gameText(size: 10)
                        .padding(.horizontal, 5)
                }
        }
        .frame(width: 220)
    }

    private var baseExp: CGFloat {
        status.baseExpNext > 0 ? CGFloat(status.baseExp) / CGFloat(status.baseExpNext) : 0
    }

    private var jobExp: CGFloat {
        status.jobExpNext > 0 ? CGFloat(status.jobExp) / CGFloat(status.jobExpNext) : 0
    }
}

private struct BasicInfoHPSPBar: View {
    var label: String
    var current: Int
    var max: Int
    var topColor: Color
    var bottomColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: label)
                .gameText()
                .frame(width: 20, alignment: .leading)

            GeometryReader { geometry in
                let fraction = max > 0 ? geometry.size.width * CGFloat(current) / CGFloat(max) : 0
                ZStack(alignment: .leading) {
                    Color(#colorLiteral(red: 0.8431372549, green: 0.8588235294, blue: 0.8745098039, alpha: 1))
                    LinearGradient(
                        colors: [topColor, bottomColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: fraction)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color(#colorLiteral(red: 0.3686274510, green: 0.3725490196, blue: 0.3803921569, alpha: 1)), lineWidth: 1)
                }
                .overlay {
                    Text(verbatim: "\(current)/\(max)")
                        .gameText(size: 9)
                }
            }
            .frame(width: 135, height: 8)
        }
        .padding(.leading, 15)
    }
}

private struct BasicInfoExpBar: View {
    var label: String
    var fraction: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: label)
                .gameText()
                .frame(width: 69, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Color.white
                    Color(#colorLiteral(red: 0.2588235294, green: 0.3843137255, blue: 0.6470588235, alpha: 1))
                        .frame(width: geo.size.width * Swift.max(0, Swift.min(1, fraction)))
                }
                .overlay {
                    Rectangle().strokeBorder(
                        Color(#colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1)),
                        lineWidth: 1
                    )
                }
            }
            .frame(width: 110, height: 4)
        }
        .padding(.leading, 15)
    }
}

#Preview {
    BasicInfoView(character: CharacterInfo(), status: CharacterStatus())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
