//
//  GameTitleBarButtonStyle.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/15.
//

import SwiftUI

struct GameTitleBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? Color(#colorLiteral(red: 0.2823529412, green: 0.3882352941, blue: 0.5568627451, alpha: 1)) : Color(#colorLiteral(red: 0.0352941176, green: 0.137254902, blue: 0.3529411765, alpha: 1)))
            .shadow(color: .white.opacity(0.35), radius: 0, x: 0.3, y: 0.3)
            .frame(width: 13, height: 13)
            .background {
                GameTitleBarButtonBackground(isPressed: configuration.isPressed)
            }
            .padding(5)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == GameTitleBarButtonStyle {
    static var gameTitleBar: GameTitleBarButtonStyle {
        GameTitleBarButtonStyle()
    }
}

private struct GameTitleBarButtonBackground: View {
    var isPressed: Bool

    var body: some View {
        Circle()
            .fill(isPressed ? pressedGradient : normalGradient)
            .overlay {
                HStack(spacing: 0) {
                    bevelGradient
                    bevelGradient
                        .rotationEffect(.degrees(180))
                }
            }
            .clipShape(Circle())
            .padding(1)
            .background {
                Circle()
                    .fill(isPressed ? pressedBorderGradient : normalBorderGradient)
            }
    }

    private var normalGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.8509803922, green: 0.8862745098, blue: 0.9568627451, alpha: 1)), location: (0 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.5254901961, green: 0.6352941176, blue: 0.862745098, alpha: 1)), location: (1 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.2745098039, green: 0.4431372549, blue: 0.7921568627, alpha: 1)), location: (2 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.4941176471, green: 0.6117647059, blue: 0.8549019608, alpha: 1)), location: (3 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.6431372549, green: 0.7254901961, blue: 0.8980392157, alpha: 1)), location: (4 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.7137254902, green: 0.7803921569, blue: 0.9176470588, alpha: 1)), location: (5 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.6784313725, green: 0.7568627451, blue: 0.9098039216, alpha: 1)), location: (6 + 0.5) / 7),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var pressedGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), location: (0 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.7607843137, green: 0.9215686275, blue: 1, alpha: 1)), location: (1 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.4078431373, green: 0.6588235294, blue: 1, alpha: 1)), location: (2 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.7411764706, green: 0.9176470588, blue: 1, alpha: 1)), location: (3 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.9529411765, green: 1, blue: 1, alpha: 1)), location: (4 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), location: (5 + 0.5) / 7),
                .init(color: Color(#colorLiteral(red: 0.9490196078, green: 1, blue: 1, alpha: 1)), location: (6 + 0.5) / 7),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var bevelGradient: LinearGradient {
        LinearGradient(
            colors: [
                (isPressed ? Color(#colorLiteral(red: 0.3137254902, green: 0.5568627451, blue: 0.9725490196, alpha: 1)) : Color(#colorLiteral(red: 0.1960784314, green: 0.368627451, blue: 0.7294117647, alpha: 1))).opacity(0.75),
                .clear,
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var normalBorderGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.1607843137, green: 0.262745098, blue: 0.4745098039, alpha: 1)), location: 0),
                .init(color: Color(#colorLiteral(red: 0.2078431373, green: 0.3137254902, blue: 0.5294117647, alpha: 1)), location: 0.35),
                .init(color: Color(#colorLiteral(red: 0.1529411765, green: 0.2588235294, blue: 0.4745098039, alpha: 1)), location: 0.5),
                .init(color: Color(#colorLiteral(red: 0.2862745098, green: 0.3960784314, blue: 0.6156862745, alpha: 1)), location: 0.625),
                .init(color: Color(#colorLiteral(red: 0.5058823529, green: 0.6039215686, blue: 0.8117647059, alpha: 1)), location: 0.75),
                .init(color: Color(#colorLiteral(red: 0.3725490196, green: 0.5215686275, blue: 0.8196078431, alpha: 1)), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var pressedBorderGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.2, green: 0.337254902, blue: 0.5764705882, alpha: 1)), location: 0),
                .init(color: Color(#colorLiteral(red: 0.2470588235, green: 0.3843137255, blue: 0.6274509804, alpha: 1)), location: 0.35),
                .init(color: Color(#colorLiteral(red: 0.1960784314, green: 0.3333333333, blue: 0.5725490196, alpha: 1)), location: 0.5),
                .init(color: Color(#colorLiteral(red: 0.3215686275, green: 0.462745098, blue: 0.7019607843, alpha: 1)), location: 0.625),
                .init(color: Color(#colorLiteral(red: 0.5215686275, green: 0.631372549, blue: 0.8509803922, alpha: 1)), location: 0.75),
                .init(color: Color(#colorLiteral(red: 0.4980392157, green: 0.6980392157, blue: 1, alpha: 1)), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    Button {
        // action
    } label: {
        Image(systemName: "xmark")
            .font(.system(size: 9, weight: .bold))
    }
    .buttonStyle(.gameTitleBar)
    .padding()
}
