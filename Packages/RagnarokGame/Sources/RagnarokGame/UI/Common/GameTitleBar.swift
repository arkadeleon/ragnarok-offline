//
//  GameTitleBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/11.
//

import SwiftUI

struct GameTitleBar: View {
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.7019607843, green: 0.7568627451, blue: 0.8666666667, alpha: 1)), location: 0.00),
                .init(color: Color(#colorLiteral(red: 0.6196078431, green: 0.7137254902, blue: 0.8941176471, alpha: 1)), location: 0.50),
                .init(color: Color(#colorLiteral(red: 0.8235294118, green: 0.9176470588, blue: 0.9882352941, alpha: 1)), location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 17)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3))
        .overlay {
            UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                .strokeBorder(Color(#colorLiteral(red: 0.5098039216, green: 0.5803921569, blue: 0.7843137255, alpha: 1)), lineWidth: 1 / displayScale)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.black).frame(height: 1)
        }
    }
}

#Preview {
    GameTitleBar()
        .frame(width: 280)
        .padding()
}
