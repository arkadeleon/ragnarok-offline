//
//  PACKET_ZC_NPC_CHAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/28.
//

import ROCore

public let HEADER_ZC_NPC_CHAT: Int16 = 0x2c1

public struct PACKET_ZC_NPC_CHAT: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var packetLength: Int16
    public var accountID: UInt32
    public var color: UInt32
    public var message: String

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        packetLength = try decoder.decode(Int16.self)
        accountID = try decoder.decode(UInt32.self)
        color = try decoder.decode(UInt32.self)
        message = try decoder.decode(String.self, lengthOfBytes: Int(packetLength - 12))
    }
}
