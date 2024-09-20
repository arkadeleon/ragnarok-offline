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

enum MessageCommand: String, CaseIterable, Identifiable {
    case login = "Login"
    case selectCharServer = "Select Char Server"
    case makeChar = "Make Char"
    case deleteChar = "Delete Char"
    case selectChar = "Select Char"

    var id: String {
        rawValue
    }

    var arguments: [String] {
        switch self {
        case .login:
            ["Username", "Password"]
        case .selectCharServer:
            ["Server Number"]
        case .makeChar:
            ["Name", "Str", "Agi", "Vit", "Int", "Dex", "Luk", "Slot"]
        case .deleteChar:
            ["Char ID"]
        case .selectChar:
            ["Slot"]
        }
    }
}
