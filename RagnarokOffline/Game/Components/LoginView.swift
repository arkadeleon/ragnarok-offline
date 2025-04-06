//
//  LoginView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/4.
//

import SwiftUI

struct LoginView: View {
    var gameSession: GameSession

    @State private var username = ClientSettings.shared.username
    @State private var password = ClientSettings.shared.password

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_login.bmp")

            TextField(String(), text: $username)
                .textFieldStyle(.plain)
                .font(.custom("Arial", fixedSize: 12))
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 29)

            TextField(String(), text: $password)
                .textFieldStyle(.plain)
                .font(.custom("Arial", fixedSize: 12))
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 61)

            Button {
            } label: {
                GameImage("login_interface/chk_saveoff.bmp")
            }
            .buttonStyle(.plain)
            .frame(width: 38, height: 10)
            .offset(x: 232, y: 32)

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    GameButton("login_interface/btn_connect.bmp") {
                        ClientSettings.shared.username = username
                        ClientSettings.shared.password = password

                        gameSession.login(username: username, password: password)
                    }

                    GameButton("login_interface/btn_exit.bmp") {
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
    LoginView(gameSession: GameSession())
}
