//
//  GameBottomBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct GameBottomBar: View {
    var height: CGFloat

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geometry in
            let stripeCount = max(0, Int((geometry.size.height + 2) / 4))

            ZStack(alignment: .top) {
                VStack(spacing: 2) {
                    ForEach(0..<stripeCount, id: \.self) { _ in
                        Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)).frame(height: 2)
                    }
                }
            }
        }
        .frame(height: height)
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3))
        .overlay {
            UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3)
                .strokeBorder(Color.gameBoxBorder, lineWidth: 1 / displayScale)
        }
        .overlay(alignment: .top) {
            Rectangle().fill(Color.gameBoxBorder).frame(height: 1 / displayScale)
        }
    }

    init(height: CGFloat = 21) {
        self.height = height
    }
}

#Preview {
    GameBottomBar()
        .frame(width: 280)
        .padding()
}
