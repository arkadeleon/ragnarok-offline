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
            GameTitleBar()

            VStack(spacing: 3) {
                // Resurrection
                GameButton("esc_05a.bmp") {
                }
                .frame(height: 20)
                .disabled(true)

                // Return to last save point
                GameButton("esc_04a.bmp") {
                    gameSession.returnToLastSavePoint()
                }
                .frame(height: 20)
                .disabled(true)

                // Character Select
                GameButton("esc_01a.bmp") {
                    gameSession.returnToCharacterSelect()
                }
                .frame(height: 20)

                // Settings
                GameButton("esc_06a.bmp") {
                }
                .frame(height: 20)
                .disabled(true)

                // Sound
                GameButton("esc_07a.bmp") {
                }
                .frame(height: 20)
                .disabled(true)

                // BM/Shortcut Settings
                GameButton("esc_08a.bmp") {
                }
                .frame(height: 20)
                .disabled(true)

                // Exit to Windows
                GameButton("esc_03a.bmp") {
                    gameSession.requestExit()
                    exitGame()
                }
                .frame(height: 20)

                // Return to game
                GameButton("esc_02a.bmp") {
                }
                .frame(height: 20)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.bottom, 6)
            .background(.white)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 3,
                    bottomTrailingRadius: 3
                )
            )
        }
        .frame(width: 280)
    }
}

#Preview {
    OptionsView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
