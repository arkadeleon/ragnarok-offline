//
//  GameBottomBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/16.
//

import SwiftUI

struct GameBottomBar: View {
    var body: some View {
        GeometryReader { geometry in
            let stripeCount = max(0, Int(geometry.size.height / 4))

            ZStack(alignment: .top) {
                VStack(spacing: 2) {
                    ForEach(0..<stripeCount, id: \.self) { _ in
                        Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)).frame(height: 2)
                    }
                }

                UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3)
                    .strokeBorder(Color.gameBoxBorder, lineWidth: 1)
            }
            .background(Color.white)
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 3, bottomTrailingRadius: 3))
        }
        .frame(height: 21)
    }
}

#Preview {
    GameBottomBar()
        .frame(width: 280)
        .padding()
}
