//
//  ChatEvents.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/18.
//

public enum ChatEvents {
    public struct MessageReceived: Event {
        public enum MessageType: Sendable {
            case `public`
            case `private`
            case `self`
            case channel
            case party
            case guild
            case clan
        }

        public let type: ChatEvents.MessageReceived.MessageType
        public let senderObjectID: UInt32
        public let senderName: String
        public let content: String
        public let color: UInt32

        init(
            type: ChatEvents.MessageReceived.MessageType,
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
}
