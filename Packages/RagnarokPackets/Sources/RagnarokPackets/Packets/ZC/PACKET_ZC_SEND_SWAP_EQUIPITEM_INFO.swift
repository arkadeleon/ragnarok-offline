//
//  PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/3/26.
//

import BinaryIO

public let HEADER_ZC_SEND_SWAP_EQUIPITEM_INFO: Int16 = 0xa9b

/// See `clif_equipswitch_list`
public struct PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO: DecodablePacket {
    public var packetType: Int16
    public var packetLength: Int16
    public var items: [PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO_sub]

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        packetLength = try decoder.decode(Int16.self)
        items = try decoder.decode([PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO_sub].self, count: Int((packetLength - 4) / 6))
    }
}

public struct PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO_sub: BinaryDecodable, Sendable {
    public var index: Int16
    public var position: UInt32

    public init(from decoder: BinaryDecoder) throws {
        index = try decoder.decode(Int16.self)
        position = try decoder.decode(UInt32.self)
    }
}
