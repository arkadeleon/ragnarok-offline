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

    var id = UUID()
    var sender: Sender
    var content: String
}

enum MessageCommand: String, CaseIterable, Identifiable {
    case login = "Login"
    case enterChar = "Enter Char"
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
        default:
            []
        }
    }
}
