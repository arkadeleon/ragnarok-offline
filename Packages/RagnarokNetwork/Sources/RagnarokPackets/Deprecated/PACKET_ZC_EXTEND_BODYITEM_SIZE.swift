//
//  PACKET_ZC_EXTEND_BODYITEM_SIZE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

/// See `clif_inventory_expansion_info`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_EXTEND_BODYITEM_SIZE: DecodablePacket {
    public static var packetType: Int16 {
        0xb18
    }

    public var packetLength: Int16 {
        2 + 2
    }

    public var expansionSize: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        expansionSize = try decoder.decode(UInt16.self)
    }
}
