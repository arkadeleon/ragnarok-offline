//
//  Message.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/12.
//

import Foundation

struct Message: Identifiable {
    enum Sender {
        case client
        case server
    }

    static func client(_ content: String) -> Message {
        Message(sender: .client, content: content)
    }

    static func server(_ content: String) -> Message {
        Message(sender: .server, content: content)
    }

    var id = UUID()
    var sender: Sender
    var content: String
}

enum MessageCommand: String, Identifiable {
    case login = "login"
    case selectCharServer = "select-char-server"
    case makeChar = "make-char"
    case deleteChar = "delete-char"
    case selectChar = "select-char"

    var id: String {
        rawValue
    }

    var arguments: [String] {
        switch self {
        case .login:
            ["--username", "--password"]
        case .selectCharServer:
            ["--server-number"]
        case .makeChar:
            ["--name", "--str", "--agi", "--vit", "--int", "--dex", "--luk", "--slot"]
        case .deleteChar:
            ["--char-id"]
        case .selectChar:
            ["--slot"]
        }
    }
}
