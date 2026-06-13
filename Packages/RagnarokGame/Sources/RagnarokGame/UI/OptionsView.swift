//
//  OptionsView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/10/16.
//

import SwiftUI

struct OptionsView: View {
    var isPlayerDead: Bool
    var onClose: () -> Void = {}

    @Environment(GameSession.self) private var gameSession
    @Environment(\.exitGame) private var exitGame

    var body: some View {
        GameWindow {
            VStack(spacing: 3) {
                if isPlayerDead {
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
                } else {
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

                    Button("Exit") {
                        gameSession.requestExit()
                        exitGame()
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                }
            }
            .padding(.vertical, 20)
        } titleBar: {
            GameTitleBar(closeAction: onClose)
        }
        .frame(width: 280)
    }
}

#Preview {
    OptionsView(isPlayerDead: false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
