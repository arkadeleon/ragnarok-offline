//
//  GameButtonStyle.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/11.
//

import SwiftUI

struct GameButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.game())
            .foregroundStyle(Color.gameLabel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                GameButtonBackground(isPressed: configuration.isPressed)
            }
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

extension ButtonStyle where Self == GameButtonStyle {
    static var game: GameButtonStyle {
        GameButtonStyle()
    }
}

private struct GameButtonBackground: View {
    var isPressed: Bool

    var body: some View {
        Rectangle()
            .fill(isPressed ? pressedGradient : normalGradient)
            .overlay {
                HStack(spacing: 0) {
                    bevelGradient
                        .frame(width: 5)
                    Spacer(minLength: 0)
                    bevelGradient
                        .rotationEffect(.degrees(180))
                        .frame(width: 5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3, style: .circular))
            .padding(1)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .circular)
                    .fill(borderGradient)
            }
    }

    private var normalGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)), location: (1 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1)), location: (2 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)), location: (4 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)), location: (5 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1)), location: (6 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)), location: (8 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)), location: (10 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)), location: (12 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)), location: (13 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)), location: (15 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)), location: (16 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)), location: (17 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.9843137255, green: 0.9843137255, blue: 0.9843137255, alpha: 1)), location: (18 - 0.5) / 18),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var pressedGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.7764705882, green: 0.8039215686, blue: 0.8588235294, alpha: 1)), location: (1 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.8, green: 0.8392156863, blue: 0.9137254902, alpha: 1)), location: (2 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.737254902, green: 0.8, blue: 0.9176470588, alpha: 1)), location: (4 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.6431372549, green: 0.7098039216, blue: 0.8352941176, alpha: 1)), location: (5 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.662745098, green: 0.737254902, blue: 0.8784313725, alpha: 1)), location: (6 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.6470588235, green: 0.7333333333, blue: 0.9019607843, alpha: 1)), location: (8 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.6509803922, green: 0.7450980392, blue: 0.9254901961, alpha: 1)), location: (10 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.6823529412, green: 0.7725490196, blue: 0.9450980392, alpha: 1)), location: (12 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.7058823529, green: 0.7960784314, blue: 0.968627451, alpha: 1)), location: (13 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.7568627451, green: 0.831372549, blue: 0.9725490196, alpha: 1)), location: (15 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.7803921569, green: 0.8470588235, blue: 0.968627451, alpha: 1)), location: (16 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.8039215686, green: 0.8549019608, blue: 0.9529411765, alpha: 1)), location: (17 - 0.5) / 18),
                .init(color: Color(#colorLiteral(red: 0.8549019608, green: 0.8941176471, blue: 0.968627451, alpha: 1)), location: (18 - 0.5) / 18),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var bevelGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(isPressed ? 0.20 : 0.22), location: 0),
                .init(color: .black.opacity(0.08), location: 0.3),
                .init(color: .black.opacity(0.02), location: 0.6),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)), location: 0),
                .init(color: Color(#colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)), location: 0.30),
                .init(color: Color(#colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)), location: 0.42),
                .init(color: Color(#colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)), location: 0.94),
                .init(color: Color(#colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)), location: 0.95),
                .init(color: Color(#colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    Grid(horizontalSpacing: 16, verticalSpacing: 12) {
        GridRow {
            Text("Normal")
            Text("Pressed")
            Text("Disabled")
        }

        GridRow {
            Button("OK") {
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)

            Text("OK")
                .font(.game())
                .foregroundStyle(Color.gameLabel)
                .frame(width: 42, height: 20)
                .background {
                    GameButtonBackground(isPressed: true)
                }

            Button("OK") {
            }
            .buttonStyle(.game)
            .frame(width: 42, height: 20)
            .disabled(true)
        }
    }
    .padding(20)
    .background(Color.gameSecondaryBoxBackground)
}
