//
//  PACKET_ZC_INVENTORY_START.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

/// See `clif_inventoryStart`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_INVENTORY_START: DecodablePacket {
    public static var packetType: Int16 {
        0xb08
    }

    public var packetLength: Int16 {
        if PACKET_VERSION_RE_NUMBER >= 20180919 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            -1
        } else {
            if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
                2 + 1 + 24
            } else {
                2 + 24
            }
        }
    }

    public var inventoryType: UInt8
    public var name: String

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        if PACKET_VERSION_RE_NUMBER >= 20180919 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            let packetLength = try decoder.decode(Int16.self)
            var remainingLength = packetLength - 4

            if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
                inventoryType = try decoder.decode(UInt8.self)
                remainingLength -= 1
            } else {
                inventoryType = 0
            }

            name = try decoder.decode(String.self, lengthOfBytes: Int(remainingLength))
        } else {
            if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
                inventoryType = try decoder.decode(UInt8.self)
            } else {
                inventoryType = 0
            }

            name = try decoder.decode(String.self, lengthOfBytes: 24)
        }
    }
}
