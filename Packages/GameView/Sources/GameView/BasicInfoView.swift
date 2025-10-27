//
//  BasicInfoView.swift
//  GameView
//
//  Created by Leon Li on 2025/4/6.
//

import RagnarokConstants
import GameCore
import RagnarokNetwork
import RagnarokPackets
import SwiftUI

struct BasicInfoView: View {
    var char: CharInfo
    var status: CharacterStatus

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("basic_interface/basewin_bg2.bmp")

            Text(char.name)
                .gameText()
                .offset(x: 10, y: 20)

            Text(JobID(rawValue: Int(char.job))?.stringValue ?? "")
                .gameText()
                .offset(x: 10, y: 33)

            VStack {
                Text(verbatim: "HP")
                Text(verbatim: "SP")
            }
            .gameText()
            .offset(x: 15, y: 50)

            VStack {
                Group {
                    Text(verbatim: "\(status.hp) / \(status.maxHp)")
                    Text(verbatim: "\(status.sp) / \(status.maxSp)")
                }
                .gameText(size: 10)
                .frame(width: 135, height: 8)
            }
            .offset(x: 35, y: 53)

            Text(verbatim: "Base Lv. \(status.baseLevel)")
                .gameText()
                .offset(x: 15, y: 86)

            Text(verbatim: "Job Lv. \(status.jobLevel)")
                .gameText()
                .offset(x: 15, y: 97)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Text(verbatim: "Weight : \(status.weight) / \(status.maxWeight) Zeny : \(status.zeny)")
                        .gameText()
                        .padding(.bottom, 3)
                        .padding(.trailing, 5)
                }
            }
        }
        .frame(width: 220, height: 135)
    }
}

#Preview {
    BasicInfoView(char: CharInfo(), status: CharacterStatus())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
