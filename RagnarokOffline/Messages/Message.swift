//
//  Message.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/12.
//

import Foundation

enum MessageSender {
    case client
    case server
}

protocol Message {
    var id: UUID { get }
    var sender: MessageSender { get }
    var content: String { get }
}
