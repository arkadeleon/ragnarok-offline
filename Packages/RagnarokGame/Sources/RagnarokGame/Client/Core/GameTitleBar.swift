//
//  GameTitleBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/11.
//

import SwiftUI

struct GameTitleBar: View {
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    .init(color: Color(#colorLiteral(red: 0.5098039216, green: 0.5803921569, blue: 0.7843137255, alpha: 1)), location: 0.0000000000),
                    .init(color: Color(#colorLiteral(red: 0.7019607843, green: 0.7568627451, blue: 0.8666666667, alpha: 1)), location: 0.0666666667),
                    .init(color: Color(#colorLiteral(red: 0.6862745098, green: 0.7450980392, blue: 0.8666666667, alpha: 1)), location: 0.1333333333),
                    .init(color: Color(#colorLiteral(red: 0.7921568627, green: 0.8313725490, blue: 0.9137254902, alpha: 1)), location: 0.2000000000),
                    .init(color: Color(#colorLiteral(red: 0.6941176471, green: 0.7686274510, blue: 0.9058823529, alpha: 1)), location: 0.2666666667),
                    .init(color: Color(#colorLiteral(red: 0.7176470588, green: 0.7764705882, blue: 0.9098039216, alpha: 1)), location: 0.3333333333),
                    .init(color: Color(#colorLiteral(red: 0.6000000000, green: 0.6823529412, blue: 0.8509803922, alpha: 1)), location: 0.4000000000),
                    .init(color: Color(#colorLiteral(red: 0.6549019608, green: 0.7294117647, blue: 0.8862745098, alpha: 1)), location: 0.4666666667),
                    .init(color: Color(#colorLiteral(red: 0.6196078431, green: 0.7137254902, blue: 0.8941176471, alpha: 1)), location: 0.5333333333),
                    .init(color: Color(#colorLiteral(red: 0.7215686275, green: 0.7921568627, blue: 0.9450980392, alpha: 1)), location: 0.6000000000),
                    .init(color: Color(#colorLiteral(red: 0.6862745098, green: 0.7686274510, blue: 0.9411764706, alpha: 1)), location: 0.6666666667),
                    .init(color: Color(#colorLiteral(red: 0.7921568627, green: 0.8745098039, blue: 0.9843137255, alpha: 1)), location: 0.7333333333),
                    .init(color: Color(#colorLiteral(red: 0.7450980392, green: 0.8470588235, blue: 0.9490196078, alpha: 1)), location: 0.8000000000),
                    .init(color: Color(#colorLiteral(red: 0.8627450980, green: 0.9450980392, blue: 0.9921568627, alpha: 1)), location: 0.8666666667),
                    .init(color: Color(#colorLiteral(red: 0.7725490196, green: 0.8705882353, blue: 0.9529411765, alpha: 1)), location: 0.9333333333),
                    .init(color: Color(#colorLiteral(red: 0.8235294118, green: 0.9176470588, blue: 0.9882352941, alpha: 1)), location: 1.0000000000),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 16)

            Color.black.frame(height: 1)
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3))
    }
}

#Preview {
    GameTitleBar()
        .frame(width: 280)
        .padding()
}
