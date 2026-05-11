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
                Button("Resurrection") {
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
                .disabled(true)

                Button("Return to last save point") {
                    gameSession.returnToLastSavePoint()
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
                .disabled(true)

                Button("Character Select") {
                    gameSession.returnToCharacterSelect()
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)

                Button("Settings") {
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
                .disabled(true)

                Button("Sound") {
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
                .disabled(true)

                Button("BM/Shortcut Settings") {
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
                .disabled(true)

                Button("Exit to Windows") {
                    gameSession.requestExit()
                    exitGame()
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)

                Button("Return to game") {
                }
                .buttonStyle(.game)
                .frame(width: 220, height: 20)
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
