//
//  GameTitleBar.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/11.
//

import SwiftUI

struct GameTitleBar: View {
    var closeAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            stripeGradient
                .overlay(alignment: .leading) {
                    Color.white.opacity(0.035)
                        .frame(width: 1)
                }
                .overlay(alignment: .trailing) {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.06)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 12)
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3, style: .circular))
                .overlay {
                    border
                }

            Color.black
                .frame(height: 1)
        }
        .frame(height: 17)
        .overlay(alignment: .trailing) {
            if let closeAction {
                GameWindowCloseButton(action: closeAction)
            }
        }
    }

    private var stripeGradient: LinearGradient {
        let colors: [Color] = [
            Color(#colorLiteral(red: 0.5098039216, green: 0.5803921569, blue: 0.7843137255, alpha: 1)),
            Color(#colorLiteral(red: 0.7019607843, green: 0.7568627451, blue: 0.8666666667, alpha: 1)),
            Color(#colorLiteral(red: 0.6862745098, green: 0.7450980392, blue: 0.8666666667, alpha: 1)),
            Color(#colorLiteral(red: 0.7921568627, green: 0.831372549, blue: 0.9137254902, alpha: 1)),
            Color(#colorLiteral(red: 0.6941176471, green: 0.768627451, blue: 0.9058823529, alpha: 1)),
            Color(#colorLiteral(red: 0.7176470588, green: 0.7764705882, blue: 0.9098039216, alpha: 1)),
            Color(#colorLiteral(red: 0.6, green: 0.6823529412, blue: 0.8509803922, alpha: 1)),
            Color(#colorLiteral(red: 0.6549019608, green: 0.7294117647, blue: 0.8862745098, alpha: 1)),
            Color(#colorLiteral(red: 0.6196078431, green: 0.7137254902, blue: 0.8941176471, alpha: 1)),
            Color(#colorLiteral(red: 0.7215686275, green: 0.7921568627, blue: 0.9450980392, alpha: 1)),
            Color(#colorLiteral(red: 0.6862745098, green: 0.768627451, blue: 0.9411764706, alpha: 1)),
            Color(#colorLiteral(red: 0.7921568627, green: 0.8745098039, blue: 0.9843137255, alpha: 1)),
            Color(#colorLiteral(red: 0.7450980392, green: 0.8470588235, blue: 0.9490196078, alpha: 1)),
            Color(#colorLiteral(red: 0.862745098, green: 0.9450980392, blue: 0.9921568627, alpha: 1)),
            Color(#colorLiteral(red: 0.7725490196, green: 0.8705882353, blue: 0.9529411765, alpha: 1)),
            Color(#colorLiteral(red: 0.8235294118, green: 0.9176470588, blue: 0.9882352941, alpha: 1)),
        ]

        return LinearGradient(
            stops: colors.enumerated().flatMap { row, color in
                [
                    Gradient.Stop(color: color, location: CGFloat(row) / 16),
                    Gradient.Stop(color: color, location: CGFloat(row + 1) / 16),
                ]
            },
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var border: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0.5, y: 3))
                path.addArc(
                    center: CGPoint(x: 3, y: 3),
                    radius: 2.5,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: geometry.size.width - 3, y: 0.5))
                path.addArc(
                    center: CGPoint(x: geometry.size.width - 3, y: 3),
                    radius: 2.5,
                    startAngle: .degrees(270),
                    endAngle: .degrees(360),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: geometry.size.width - 0.5, y: geometry.size.height))
            }
            .stroke(
                LinearGradient(
                    stops: [
                        .init(color: Color(#colorLiteral(red: 0.8392156863, green: 0.8784313725, blue: 0.9490196078, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.5098039216, green: 0.5803921569, blue: 0.7843137255, alpha: 1)), location: min(4 / max(geometry.size.width, 1), 1)),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1
            )
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    GameTitleBar {
        // close action
    }
    .frame(width: 280)
    .padding()
}
