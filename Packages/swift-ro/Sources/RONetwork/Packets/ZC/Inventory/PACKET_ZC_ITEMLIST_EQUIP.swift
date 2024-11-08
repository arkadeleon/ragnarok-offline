//
//  PACKET_ZC_ITEMLIST_EQUIP.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_inventorylist`
public struct PACKET_ZC_ITEMLIST_EQUIP: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION_MAIN_NUMBER >= 20200916 || PACKET_VERSION_RE_NUMBER >= 20200723 || PACKET_VERSION_ZERO_NUMBER >= 20221024 {
            0xb39
        } else if PACKET_VERSION_MAIN_NUMBER >= 20181002 || PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 {
            0xb0a
        } else if PACKET_VERSION >= 20150226 {
            0xa0d
        } else if PACKET_VERSION >= 20120925 {
            0x992
        } else if PACKET_VERSION >= 20080102 {
            0x2d0
        } else if PACKET_VERSION >= 20071002 {
            0x295
        } else {
            0xa4
        }
    }

    public var packetLength: Int16 {
        -1
    }

    public var inventoryType: UInt8
    public var items: [EquipItemInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)
        var remainingLength = packetLength - 4

        if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            inventoryType = try decoder.decode(UInt8.self)
            remainingLength -= 1
        } else {
            inventoryType = 0
        }

        let itemCount = remainingLength / EquipItemInfo.decodedLength

        items = []
        for _ in 0..<itemCount {
            let item = try EquipItemInfo(from: decoder)
            items.append(item)
        }
    }
}
