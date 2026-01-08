//
//  OptionsView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/16.
//

import SwiftUI

struct OptionsView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(\.exitGame) private var exitGame

    var body: some View {
        VStack(spacing: 0) {
            GameImage("basic_interface/titlebar_fix.bmp")

            VStack(spacing: 3) {
                // Resurrection
                GameButton("esc_05a.bmp") {
                }
                .disabled(true)

                // Return to last save point
                GameButton("esc_04a.bmp") {
                    gameSession.returnToLastSavePoint()
                }
                .disabled(true)

                // Character Select
                GameButton("esc_01a.bmp") {
                    gameSession.returnToCharacterSelect()
                }

                // Settings
                GameButton("esc_06a.bmp") {
                }
                .disabled(true)

                // Sound
                GameButton("esc_07a.bmp") {
                }
                .disabled(true)

                // BM/Shortcut Settings
                GameButton("esc_08a.bmp") {
                }
                .disabled(true)

                // Exit to Windows
                GameButton("esc_03a.bmp") {
                    gameSession.requestExit()
                    exitGame()
                }

                // Return to game
                GameButton("esc_02a.bmp") {
                }
            }
            .frame(width: 280)
            .padding(.top, 20)
            .padding(.bottom, 6)
            .background(.white)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 5,
                    bottomTrailingRadius: 5
                )
            )
        }
    }
}

#Preview {
    OptionsView()
        .environment(GameSession.testing)
}
