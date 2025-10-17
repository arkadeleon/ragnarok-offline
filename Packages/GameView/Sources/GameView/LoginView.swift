//
//  LoginView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/4.
//

import GameCore
import SwiftUI

struct LoginView: View {
    @Environment(GameSession.self) private var gameSession
    @Environment(\.exitGame) private var exitGame

    @AppStorage("game.username") private var username = ""
    @AppStorage("game.password") private var password = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_login.bmp")

            TextField(String(), text: $username)
                .textFieldStyle(.plain)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .gameText()
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 29)

            TextField(String(), text: $password)
                .textFieldStyle(.plain)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .gameText()
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 61)

            Button {
            } label: {
                GameImage("login_interface/chk_saveoff.bmp")
            }
            .buttonStyle(.borderless)
            .frame(width: 38, height: 10)
            .offset(x: 232, y: 32)

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    GameButton("login_interface/btn_connect.bmp") {
                        gameSession.login(
                            username: username,
                            password: password
                        )
                    }

                    GameButton("login_interface/btn_exit.bmp") {
                        exitGame()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 4)
            }
        }
        .frame(width: 280, height: 120)
    }
}

#Preview {
    ZStack {
        GameImage("bgi_temp.bmp") { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .ignoresSafeArea()

        LoginView()
    }
    .environment(GameSession.previewing)
}
