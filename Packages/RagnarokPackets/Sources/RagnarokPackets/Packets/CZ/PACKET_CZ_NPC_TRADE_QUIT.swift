//
//  PACKET_CZ_NPC_TRADE_QUIT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/9/16.
//

import BinaryIO

public let HEADER_CZ_NPC_TRADE_QUIT: Int16 = 0x9d4

/// See `clif_parse_NPCShopClosed`
public struct PACKET_CZ_NPC_TRADE_QUIT: EncodablePacket {
    public var packetType: Int16 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
