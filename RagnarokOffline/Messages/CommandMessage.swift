//
//  CommandMessage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/29.
//

import Foundation

struct CommandMessage: Message {
    let id = UUID()

    var command: Command
    var parameters: [String]

    var sender: MessageSender {
        .client
    }

    var content: String {
        var content = "$" + command.rawValue
        for (index, argument) in command.arguments.enumerated() {
            content.append("\n")
            content.append("--\(argument) \(parameters[index])")
        }
        return content
    }
}

extension CommandMessage {
    enum Command: String {
        case login = "login"
        case selectCharServer = "select-char-server"
        case makeChar = "make-char"
        case deleteChar = "delete-char"
        case selectChar = "select-char"
        case moveUp = "move-up"
        case moveDown = "move-down"
        case moveLeft = "move-left"
        case moveRight = "move-right"

        var arguments: [String] {
            switch self {
            case .login:
                ["username", "password"]
            case .selectCharServer:
                ["server-number"]
            case .makeChar:
                ["name", "str", "agi", "vit", "int", "dex", "luk", "slot"]
            case .deleteChar:
                ["char-id"]
            case .selectChar:
                ["slot"]
            case .moveUp, .moveDown, .moveLeft, .moveRight:
                []
            }
        }
    }
}

extension Message where Self == CommandMessage {
    static func command(_ command: CommandMessage.Command, parameters: [String]) -> CommandMessage {
        CommandMessage(command: command, parameters: parameters)
    }
}
