//
//  TextMessage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/29.
//

import Foundation

struct TextMessage: Message {
    let id = UUID()

    var sender: MessageSender
    var text: String

    var content: String {
        text
    }
}

extension Message where Self == TextMessage {
    static func clientText(_ text: String) -> TextMessage {
        TextMessage(sender: .client, text: text)
    }

    static func serverText(_ text: String) -> TextMessage {
        TextMessage(sender: .server, text: text)
    }
}
