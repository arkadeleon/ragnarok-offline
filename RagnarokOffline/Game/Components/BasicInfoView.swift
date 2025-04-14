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
    var status: Player.Status

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("basic_interface/basewin_bg2.bmp")

            GameText(char.name)
                .offset(x: 10, y: 20)

            GameText(JobID(rawValue: Int(char.job))?.stringValue ?? "")
                .offset(x: 10, y: 33)

            GameText("HP")
                .offset(x: 15, y: 50)

            GameText("\(status.hp) / \(status.maxHp)", size: 10)
                .frame(width: 135, height: 8)
                .offset(x: 35, y: 53)

            GameText("SP")
                .offset(x: 15, y: 65)

            GameText("\(status.sp) / \(status.maxSp)", size: 10)
                .frame(width: 135, height: 8)
                .offset(x: 35, y: 68)

            GameText("Base Lv. \(status.baseLevel)")
                .offset(x: 15, y: 86)

            GameText("Job Lv. \(status.jobLevel)")
                .offset(x: 15, y: 97)

            GameText("Weight : \(status.weight) / \(status.maxWeight) Zeny : \(status.zeny)")
                .frame(width: 210, alignment: .trailing)
                .offset(x: 5, y: 118)
        }
        .frame(width: 220, height: 135)
    }
}

#Preview {
    BasicInfoView(char: CharInfo(), status: Player.Status())
}
