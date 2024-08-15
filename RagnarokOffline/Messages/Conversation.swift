//
//  Conversation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/15.
//

import Observation
import RONetwork

@Observable
class Conversation {
    var messages: [Message] = []

    private var loginClient: LoginClient!
    private var charClient: CharClient!

    func showCommand(_ command: MessageCommand) {
        let message = Message(sender: .client, content: command.rawValue)
        messages.append(message)
    }

    func executeCommand(_ command: MessageCommand, arguments: [String] = []) {
        if !arguments.isEmpty {
            let messageContent = command.arguments.enumerated()
                .map {
                    "\($0.element): \(arguments[$0.offset])"
                }
                .joined(separator: "\n")
            let message = Message(sender: .client, content: messageContent)
            messages.append(message)
        }

        switch command {
        case .login:
            loginClient = LoginClient()
            loginClient.onAcceptLogin = { state, serverList in
                let message = Message(sender: .server, content: "ACCEPT_LOGIN")
                self.messages.append(message)
            }
            loginClient.onRefuseLogin = { message in
                let message = Message(sender: .server, content: "REFUSE_LOGIN: \(message)")
                self.messages.append(message)
            }
            loginClient.onNotifyBan = { message in
                let message = Message(sender: .server, content: "NOTIFY_BAN")
                self.messages.append(message)
            }
            loginClient.onError = { error in
                let message = Message(sender: .server, content: error.localizedDescription)
                self.messages.append(message)
            }

            loginClient.connect()

            let username = arguments[0]
            let password = arguments[1]
            loginClient.login(username: username, password: password)
        default:
            break
        }
    }
}
