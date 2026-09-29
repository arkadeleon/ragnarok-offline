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
        // login_interface/win_login.bmp
        GameWindow {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 10) {
                    Text("ID", bundle: #bundle)
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameProminentLabel)
                        .frame(width: 70, alignment: .trailing)

                    TextField(String(), text: $username)
                        .textFieldStyle(.plain)
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .padding(.horizontal, 3)
                        .frame(width: 127, height: 18)
                        .background(Color.gameSecondaryBoxBackground)
                        .overlay {
                            Rectangle()
                                .strokeBorder(Color.gameBoxBorder)
                        }

                    Spacer()
                }

                HStack(spacing: 10) {
                    Text("Password", bundle: #bundle)
                        .font(.game(weight: .bold))
                        .foregroundStyle(Color.gameProminentLabel)
                        .frame(width: 70, alignment: .trailing)

                    SecureField(String(), text: $password)
                        .textFieldStyle(.plain)
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .disableAutocorrection(true)
                        .font(.game())
                        .foregroundStyle(Color.gameLabel)
                        .padding(.horizontal, 3)
                        .frame(width: 127, height: 18)
                        .background(Color.gameSecondaryBoxBackground)
                        .overlay {
                            Rectangle()
                                .strokeBorder(Color.gameBoxBorder)
                        }

                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 13)
        } bottomBar: {
            GameBottomBar {
                // login_interface/btn_connect.bmp
                Button {
                    gameSession.audioPlayer.playButtonSoundEffect()
                    gameSession.login(username: username, password: password)
                    username = usernameWithoutSuffix
                } label: {
                    Text("login", bundle: #bundle)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
                .disabled(!isValidUsername || !isValidPassword)

                // login_interface/btn_exit.bmp
                Button {
                    gameSession.exitSession()
                    exitGame()
                } label: {
                    Text("exit", bundle: #bundle)
                }
                .buttonStyle(.game)
                .frame(width: 42, height: 20)
            }
        }
        .gameWindowTitle(Text("LogOn", bundle: #bundle))
        .frame(width: 280)
    }

    private var usernameWithoutSuffix: String {
        username.replacingOccurrences(
            of: "_[mMfF]$",
            with: "",
            options: .regularExpression
        )
    }

    private var isValidUsername: Bool {
        usernameWithoutSuffix.count >= 6
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
