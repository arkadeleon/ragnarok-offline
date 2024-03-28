//
//  ConnectionTestView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ConnectionTestView: View {
    private let loginClient = LoginClient()

    @State private var isLoginAlertPresented = false
    @State private var username = ""
    @State private var password = ""

    @State private var isAcceptLoginAlertPresented = false
    @State private var isRefuseLoginAlertPresented = false
    @State private var isNotifyBanAlertPresented = false

    var body: some View {
        List {
            Button("Connect to Login Server") {
                loginClient.connect()
            }
            Button("Login") {
                isLoginAlertPresented.toggle()
            }
        }
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
        .alert("", isPresented: $isLoginAlertPresented) {
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            Button("Login") {
                try? loginClient.login(username: username, password: password)
            }
        }
        .alert("Accept Login", isPresented: $isAcceptLoginAlertPresented) {
            Button("OK") {

            }
        }
        .alert("Refuse Login", isPresented: $isRefuseLoginAlertPresented) {
            Button("OK") {

            }
        }
        .alert("Notify Ban", isPresented: $isNotifyBanAlertPresented) {
            Button("OK") {

            }
        }
        .task {
            loginClient.onAcceptLogin = {
                isAcceptLoginAlertPresented.toggle()
            }
            loginClient.onRefuseLogin = {
                isRefuseLoginAlertPresented.toggle()
            }
            loginClient.onNotifyBan = {
                isNotifyBanAlertPresented.toggle()
            }
        }
    }
}

#Preview {
    ConnectionTestView()
}
