//
//  PACKET_ZC_INVENTORY_END.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_inventoryEnd`
public struct PACKET_ZC_INVENTORY_END: DecodablePacket {
    public static var packetType: Int16 {
        0xb0b
    }

    public var packetLength: Int16 {
        if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            2 + 1 + 1
        } else {
            2 + 1
        }
    }

    public var inventoryType: UInt8
    public var flag: Int8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            inventoryType = try decoder.decode(UInt8.self)
        } else {
            inventoryType = 0
        }

        flag = try decoder.decode(Int8.self)
    }
}
