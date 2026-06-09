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

private struct GameButtonBackground: View {
    var isPressed: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(white: 0.66),
                        Color(white: 0.43),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(isPressed ? pressedGradient : normalGradient)
                    .padding(1)
            }
    }

    private var normalGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(white: 0.87),
                Color(white: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var pressedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.64, green: 0.71, blue: 0.84),
                Color(red: 0.85, green: 0.89, blue: 0.97),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension ButtonStyle where Self == GameButtonStyle {
    static var game: GameButtonStyle {
        GameButtonStyle()
    }
}

#Preview {
    Button("OK") {
    }
    .buttonStyle(.game)
    .frame(width: 42, height: 20)
}
