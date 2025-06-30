//
//  BasicInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/6.
//

import ROConstants
import RONetwork
import ROPackets
import SwiftUI

struct BasicInfoView: View {
    var char: CharInfo
    var status: CharacterStatus

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("basic_interface/basewin_bg2.bmp")

            GameText(char.name)
                .offset(x: 10, y: 20)

            GameText(JobID(rawValue: Int(char.job))?.stringValue ?? "")
                .offset(x: 10, y: 33)

            VStack {
                GameText("HP")
                GameText("SP")
            }
            .offset(x: 15, y: 50)

            VStack {
                Group {
                    GameText("\(status.hp) / \(status.maxHp)", size: 10)
                    GameText("\(status.sp) / \(status.maxSp)", size: 10)
                }
                .frame(width: 135, height: 8)
            }
            .offset(x: 35, y: 53)

            GameText("Base Lv. \(status.baseLevel)")
                .offset(x: 15, y: 86)

            GameText("Job Lv. \(status.jobLevel)")
                .offset(x: 15, y: 97)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    GameText("Weight : \(status.weight) / \(status.maxWeight) Zeny : \(status.zeny)")
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
        .padding()
}
