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
    private var charClient: CharClient?

    private var state: ClientState?
    private var charServers: [CharServerInfo] = []

    func executeCommand(_ command: MessageCommand, arguments: [String] = []) {
        let message = Message(sender: .client, content: command.rawValue)
        messages.append(message)

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
            loginClient.onAcceptLogin = { [weak self] state, charServers in
                self?.state = state
                self?.charServers = charServers

                self?.messages.append(.server("Accepted"))

                let serversMessage = charServers.enumerated()
                    .map({ "(\($0.offset + 1)) \($0.element.name)" })
                    .joined(separator: "\n")
                self?.messages.append(.server(serversMessage))
            }
            loginClient.onRefuseLogin = { [weak self] message in
                self?.messages.append(.server("Refused"))
                self?.messages.append(.server(message))
            }
            loginClient.onNotifyBan = { [weak self] message in
                self?.messages.append(.server("Banned"))
                self?.messages.append(.server(message))
            }
            loginClient.onError = { [weak self] error in
                self?.messages.append(.server(error.localizedDescription))
            }

            loginClient.connect()

            let username = arguments[0]
            let password = arguments[1]
            loginClient.login(username: username, password: password)
        case .enterChar:
            guard let state,
                  let serverNumber = Int(arguments[0]),
                  (serverNumber - 1) < charServers.count else {
                break
            }

            let charServer = charServers[serverNumber - 1]
            charClient = CharClient(state: state, charServer: charServer)
            charClient?.onAcceptEnter = { [weak self] chars in
                self?.messages.append(.server("Accepted"))

                for charInfo in chars {
                    let message = """
                    Char ID: \(charInfo.charID)
                    Name: \(charInfo.name)
                    Str: \(charInfo.str)
                    Agi: \(charInfo.agi)
                    Vit: \(charInfo.vit)
                    Int: \(charInfo.int)
                    Dex: \(charInfo.dex)
                    Luk: \(charInfo.luk)
                    Char Number: \(charInfo.slot)
                    """
                    self?.messages.append(.server(message))
                }
            }
            charClient?.onRefuseEnter = { [weak self] in
                self?.messages.append(.server("Refused"))
            }
            charClient?.onAcceptMakeChar = { [weak self] in
                self?.messages.append(.server("Accepted"))
            }
            charClient?.onRefuseMakeChar = { [weak self] in
                self?.messages.append(.server("Refused"))
            }
            charClient?.onNotifyZoneServer = { [weak self] mapName, mapServer in
                self?.messages.append(.server("Entered map: \(mapName)"))
            }

            charClient?.connect()

            charClient?.enter()
        case .makeChar:
            let name = arguments[0]
            let str = UInt8(arguments[1]) ?? 1
            let agi = UInt8(arguments[2]) ?? 1
            let vit = UInt8(arguments[3]) ?? 1
            let int = UInt8(arguments[4]) ?? 1
            let dex = UInt8(arguments[5]) ?? 1
            let luk = UInt8(arguments[6]) ?? 1

            charClient?.makeChar(name: name, str: str, agi: agi, vit: vit, int: int, dex: dex, luk: luk)
        case .deleteChar:
            break
        case .selectChar:
            guard let charNum = UInt8(arguments[0]) else {
                break
            }

            charClient?.selectChar(slot: charNum)
        }
    }
}
