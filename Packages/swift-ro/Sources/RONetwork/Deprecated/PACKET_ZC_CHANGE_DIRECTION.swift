//
//  PACKET_ZC_CHANGE_DIRECTION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import ROCore

/// See `clif_changed_dir`
public struct _PACKET_ZC_CHANGE_DIRECTION: DecodablePacket {
    public static var packetType: Int16 {
        0x9c
    }

    public var packetLength: Int16 {
        2 + 4 + 2 + 1
    }

    public var sourceID: UInt32
    public var headDirection: UInt16
    public var direction: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        sourceID = try decoder.decode(UInt32.self)
        headDirection = try decoder.decode(UInt16.self)
        direction = try decoder.decode(UInt8.self)
    }
}
