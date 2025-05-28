//
//  PACKET_ZC_NPCACK_MAPMOVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import BinaryIO

/// See `clif_changemap`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_NPCACK_MAPMOVE: DecodablePacket {
    public static var packetType: Int16 {
        0x91
    }

    public var packetLength: Int16 {
        2 + 16 + 2 + 2
    }

    public var mapName: String
    public var x: UInt16
    public var y: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        mapName = try decoder.decode(String.self, lengthOfBytes: 16)
        x = try decoder.decode(UInt16.self)
        y = try decoder.decode(UInt16.self)
    }
}
