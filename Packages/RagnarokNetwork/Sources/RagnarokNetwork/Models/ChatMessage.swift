//
//  ChatMessage.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/10/21.
//

public struct ChatMessage: Sendable {
    public enum MessageType: Sendable {
        case `public`
        case `private`
        case `self`
        case channel
        case party
        case guild
        case clan
    }

    public let type: ChatMessage.MessageType
    public let senderObjectID: UInt32
    public let senderName: String
    public let content: String
    public let color: UInt32

    init(
        type: ChatMessage.MessageType,
        senderObjectID: UInt32 = 0,
        senderName: String = "",
        content: String,
        color: UInt32 = 0
    ) {
        self.type = type
        self.senderObjectID = senderObjectID
        self.senderName = senderName
        self.content = content
        self.color = color
    }
}
