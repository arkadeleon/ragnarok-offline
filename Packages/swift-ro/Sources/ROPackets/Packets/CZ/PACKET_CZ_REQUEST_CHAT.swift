//
//  PACKET_CZ_REQUEST_CHAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/4/16.
//

import Foundation
import ROCore

let ENTRY_CZ_REQUEST_CHAT = packetDatabase.entry(forFunctionName: "clif_parse_GlobalMessage")!

public struct PACKET_CZ_REQUEST_CHAT: BinaryEncodable {
    public let packetType: Int16
    public let packetLength: Int16
    public var message: String

    public init() {
        packetType = ENTRY_CZ_REQUEST_CHAT.packetType
        packetLength = ENTRY_CZ_REQUEST_CHAT.packetLength
        message = ""
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let messageData = message.data(using: .utf8) ?? Data()

        let packetLength: Int16 = 2 + 2 + Int16(messageData.count)
        let offsets = ENTRY_CZ_REQUEST_CHAT.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: packetLength)
        data.replaceSubrange(from: offsets[1], with: messageData)

        try encoder.encode(data)
    }
}
