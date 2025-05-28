//
//  PACKET_ZC_ITEMLIST_NORMAL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

/// See `clif_inventorylist`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_ITEMLIST_NORMAL: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION_RE_NUMBER >= 20180912 || PACKET_VERSION_ZERO_NUMBER >= 20180919 || PACKET_VERSION_MAIN_NUMBER >= 20181002 {
            0xb09
        } else if PACKET_VERSION >= 20120925 {
            0x991
        } else if PACKET_VERSION >= 20080102 {
            0x2e8
        } else if PACKET_VERSION >= 20071002 {
            0x1ee
        } else {
            0xa3
        }
    }

    public var packetLength: Int16 {
        -1
    }

    public var inventoryType: UInt8
    public var items: [_NormalItemInfo]

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

        let itemCount = remainingLength / _NormalItemInfo.decodedLength

        items = []
        for _ in 0..<itemCount {
            let item = try _NormalItemInfo(from: decoder)
            items.append(item)
        }
    }
}
