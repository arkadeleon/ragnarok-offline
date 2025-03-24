//
//  PACKET_ZC_NOTIFY_PLAYERMOVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/24.
//

import ROCore

/// See `clif_walkok`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_NOTIFY_PLAYERMOVE: DecodablePacket {
    public static var packetType: Int16 {
        0x87
    }

    public var packetLength: Int16 {
        2 + 2 + 6
    }

    public var moveStartTime: UInt32
    public var moveData: [UInt8]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        moveStartTime = try decoder.decode(UInt32.self)
        moveData = try decoder.decode([UInt8].self, count: 6)
    }
}
