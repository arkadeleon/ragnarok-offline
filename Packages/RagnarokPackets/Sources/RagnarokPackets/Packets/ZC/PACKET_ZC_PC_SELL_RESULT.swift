//
//  PACKET_ZC_PC_SELL_RESULT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/9/16.
//

import BinaryIO

public let HEADER_ZC_PC_SELL_RESULT: Int16 = 0xcb

/// See `clif_npc_sell_result`
public struct PACKET_ZC_PC_SELL_RESULT: DecodablePacket {
    public var packetType: Int16
    public var result: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        result = try decoder.decode(UInt8.self)
    }
}
