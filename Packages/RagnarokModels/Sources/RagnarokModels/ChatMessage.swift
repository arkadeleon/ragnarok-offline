//
//  ChatMessage.swift
//  RagnarokModels
//
//  Created by Leon Li on 2025/10/21.
//

import RagnarokPackets

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

    public init(
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

    public init(from packet: PACKET_ZC_NOTIFY_CHAT) {
        self.init(
            type: .public,
            senderObjectID: packet.GID,
            content: packet.Message
        )
    }

    public init(from packet: PACKET_ZC_WHISPER) {
        self.init(
            type: .private,
            senderObjectID: packet.senderGID,
            senderName: packet.sender,
            content: packet.message
        )
    }

    public init(from packet: PACKET_ZC_NOTIFY_PLAYERCHAT) {
        self.init(
            type: .`self`,
            content: packet.Message
        )
    }

    public init(from packet: PACKET_ZC_NPC_CHAT) {
        self.init(
            type: .channel,
            senderObjectID: packet.accountID,
            content: packet.message,
            color: packet.color
        )
    }

    public init(from packet: PACKET_ZC_NOTIFY_CHAT_PARTY) {
        self.init(
            type: .party,
            senderObjectID: UInt32(packet.AID),
            content: packet.chatMsg
        )
    }

    public init(from packet: PACKET_ZC_GUILD_CHAT) {
        self.init(
            type: .guild,
            content: packet.message
        )
    }

    public init(from packet: PACKET_ZC_NOTIFY_CLAN_CHAT) {
        self.init(
            type: .clan,
            senderName: packet.MemberName,
            content: packet.Message
        )
    }
}
