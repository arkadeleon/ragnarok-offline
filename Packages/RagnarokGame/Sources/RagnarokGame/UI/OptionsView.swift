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
                    Button {
                    } label: {
                        Text("Resurrection", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                    .disabled(true)

                    Button {
                        gameSession.returnToLastSavePoint()
                    } label: {
                        Text("Return to last save point", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                } else {
                    Button {
                        gameSession.returnToCharacterSelect()
                    } label: {
                        Text("Character Select", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)

                    Button {
                    } label: {
                        Text("Settings", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                    .disabled(true)

                    Button {
                    } label: {
                        Text("Sound", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                    .disabled(true)

                    Button {
                    } label: {
                        Text("BM/Shortcut Settings", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                    .disabled(true)

                    Button {
                        gameSession.requestExit()
                        gameSession.exitSession()
                        exitGame()
                    } label: {
                        Text("Exit", bundle: #bundle)
                    }
                    .buttonStyle(.game)
                    .frame(width: 220, height: 20)
                }
            }
            .padding(.vertical, 20)
        }
        .gameWindowCloseAction(onClose)
        .frame(width: 280)
    }
}

#Preview {
    OptionsView(isPlayerDead: false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
