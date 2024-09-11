//
//  Login.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/4.
//

import SwiftUI

struct Login: View {
    @Environment(\.gameSession) private var gameSession

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            ROImage("win_login")

            TextField("", text: $username)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 29)

            TextField("", text: $password)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .frame(width: 127, height: 18)
                .offset(x: 91, y: 61)

            Button {
            } label: {
                ROImage("chk_saveoff")
            }
            .frame(width: 38, height: 10)
            .offset(x: 232, y: 32)

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    Spacer()

                    ROButton("btn_connect") {
                        gameSession.login(username: username, password: password)
                    }

                    ROButton("btn_exit") {
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
    Login()
}
