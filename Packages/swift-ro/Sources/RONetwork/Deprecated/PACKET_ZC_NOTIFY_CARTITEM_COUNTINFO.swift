//
//  PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

import ROCore

/// See `clif_cartcount`
@available(*, deprecated, message: "Use `ROGenerated` instead.")
public struct _PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO: DecodablePacket {
    public static var packetType: Int16 {
        0x121
    }

    public var packetLength: Int16 {
        2 + 2 + 2 + 4 + 4
    }

    public var currentCount: Int16
    public var maxCount: Int16
    public var currentWeight: Int32
    public var maxWeight: Int32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        currentCount = try decoder.decode(Int16.self)
        maxCount = try decoder.decode(Int16.self)
        currentWeight = try decoder.decode(Int32.self)
        maxWeight = try decoder.decode(Int32.self)
    }
}
