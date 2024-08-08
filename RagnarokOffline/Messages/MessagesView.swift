//
//  MessagesView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

import SwiftUI
import ROClient

struct MessagesView: View {
    @State private var loginClient = LoginClient()

    @State private var messages: [Message] = []
    @State private var editingMessageContent = ""

    @State private var isLoginAlertPresented = false
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageCell(message: message)
                        }
                    }
                }
            }

            HStack {
                TextField("", text: $editingMessageContent)
                    .textFieldStyle(.roundedBorder)
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
        .navigationTitle("Messages")
        .alert("", isPresented: $isLoginAlertPresented) {
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            Button("Login") {
                loginClient.connect()
                try? loginClient.login(username: username, password: password)
            }
        }
        .task {
            loginClient.onAcceptLogin = {
                let message = Message(sender: .server, content: "ACCEPT_LOGIN")
                messages.append(message)
            }
            loginClient.onRefuseLogin = {
                let message = Message(sender: .server, content: "REFUSE_LOGIN")
                messages.append(message)
            }
            loginClient.onNotifyBan = {
                let message = Message(sender: .server, content: "NOTIFY_BAN")
                messages.append(message)
            }
            loginClient.onError = { error in
                let message = Message(sender: .server, content: error.localizedDescription)
                messages.append(message)
            }
        }
    }

    private func sendMessage() {
        guard !editingMessageContent.isEmpty else {
            return
        }

        let message = Message(sender: .client, content: editingMessageContent)
        messages.append(message)

        switch editingMessageContent.lowercased() {
        case "login":
            isLoginAlertPresented.toggle()
        default:
            break
        }

        editingMessageContent = ""
    }
}

#Preview {
    MessagesView()
}
