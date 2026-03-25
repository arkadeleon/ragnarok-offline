//
//  GaugeView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/30.
//

import RagnarokModels
import SwiftUI

struct GaugeView: View {
    var hp: Int
    var maxHp: Int
    var sp: Int?
    var maxSp: Int?
    var objectType: MapObjectType

    var body: some View {
        VStack(spacing: 0) {
            GaugeBar(
                percentage: hpPercentage,
                fillColor: hpFillColor
            )

            if let sp, let maxSp {
                GaugeBar(
                    percentage: CGFloat(sp) / CGFloat(maxSp),
                    fillColor: Color(#colorLiteral(red: 0.09411764706, green: 0.3882352941, blue: 0.8705882353, alpha: 1))
                )
                .offset(y: -1)
            }
        }
    }

    private var hpPercentage: CGFloat {
        CGFloat(hp) / CGFloat(maxHp)
    }

    private var hpFillColor: Color {
        switch objectType {
        case .monster, .abr, .bionic:
            hpPercentage < 0.25 ? Color(#colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)) : Color(#colorLiteral(red: 1, green: 0, blue: 0.9058823529, alpha: 1))
        default:
            hpPercentage < 0.25 ? Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)) : Color(#colorLiteral(red: 0.06274509804, green: 0.937254902, blue: 0.1294117647, alpha: 1))
        }
    }
}

private struct GaugeBar: View {
    private let barWidth: CGFloat = 60
    private let barHeight: CGFloat = 6

    var percentage: CGFloat
    var fillColor: Color

    var body: some View {
        ZStack(alignment: .leading) {
            // Border
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(#colorLiteral(red: 0.06274509804, green: 0.09411764706, blue: 0.6117647059, alpha: 1)))
                .frame(width: barWidth, height: barHeight)

            // Background
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(#colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)))
                .frame(width: barWidth - 2, height: barHeight - 2)
                .offset(x: 1)

            // Fill
            RoundedRectangle(cornerRadius: 1)
                .fill(fillColor)
                .frame(width: max(0, (barWidth - 2) * percentage), height: barHeight - 2)
                .offset(x: 1)
        }
    }
}

#Preview {
    GaugeView(hp: 75, maxHp: 100, sp: 50, maxSp: 100, objectType: .pc)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
