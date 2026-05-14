//
//  LoginView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/4.
//

import SwiftUI

struct LoginView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(\.exitGame) private var exitGame

    @AppStorage("game.username") private var username = ""
    @AppStorage("game.password") private var password = ""

    var body: some View {
        GameWindow {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 10) {
                    Text("ID")
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameProminentLabel)
                        .frame(width: 70, alignment: .trailing)

                    TextField(String(), text: $username)
                        .textFieldStyle(.plain)
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                        .gameText()
                        .padding(.horizontal, 3)
                        .frame(width: 127, height: 18)
                        .background(Color.gameSecondaryBoxBackground)
                        .overlay {
                            Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1)
                        }

                    Spacer()
                }

                HStack(spacing: 10) {
                    Text("Password")
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameProminentLabel)
                        .frame(width: 70, alignment: .trailing)

                    TextField(String(), text: $password)
                        .textFieldStyle(.plain)
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                        .gameText()
                        .padding(.horizontal, 3)
                        .frame(width: 127, height: 18)
                        .background(Color.gameSecondaryBoxBackground)
                        .overlay {
                            Rectangle().strokeBorder(Color.gameBoxBorder, lineWidth: 1)
                        }

                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 13)
        } bottomBar: {
            GameBottomBar(height: 28)
                .overlay(alignment: .trailing) {
                    HStack(spacing: 3) {
                        Button("login") {
                            gameSession.loginAudioPlayer.playButtonSound()
                            gameSession.login(
                                username: username,
                                password: password
                            )
                        }
                        .buttonStyle(.game)
                        .frame(width: 42, height: 20)
                        .disabled(!isValidUsername || !isValidPassword)

                        Button("exit") {
                            exitGame()
                        }
                        .buttonStyle(.game)
                        .frame(width: 42, height: 20)
                    }
                    .padding(.horizontal, 5)
                }
        }
        .frame(width: 280)
    }

    private var isValidUsername: Bool {
        let username = username.replacingOccurrences(
            of: "_[mMfF]$",
            with: "",
            options: .regularExpression
        )
        return username.count >= 6
    }

    private var isValidPassword: Bool {
        password.count >= 6
    }
}

#Preview {
    LoginView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
