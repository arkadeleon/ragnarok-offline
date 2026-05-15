//
//  GameWindowCloseButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/14.
//

import SwiftUI

struct GameWindowCloseButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.85, green: 0.89, blue: 0.96), location: 0),
                                .init(color: Color(red: 0.27, green: 0.44, blue: 0.79), location: 0.4),
                                .init(color: Color(red: 0.68, green: 0.76, blue: 0.91), location: 1),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Circle().strokeBorder(Color(red: 0.16, green: 0.26, blue: 0.47), lineWidth: 1)
                    }

                ZStack {
                    Capsule().frame(width: 7, height: 1.5).rotationEffect(.degrees(45))
                    Capsule().frame(width: 7, height: 1.5).rotationEffect(.degrees(-45))
                }
                .foregroundStyle(Color(red: 0.03, green: 0.13, blue: 0.34))
            }
            .frame(width: 13, height: 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(GameWindowCloseButtonStyle())
    }
}

private struct GameWindowCloseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.3 : 0)
    }
}

#Preview {
    GameWindowCloseButton {}
        .padding()
}
