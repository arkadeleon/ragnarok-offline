//
//  PACKET_ZC_ATTACK_RANGE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/27.
//

import BinaryIO

/// See `clif_attackrange`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_ATTACK_RANGE: DecodablePacket {
    public static var packetType: Int16 {
        0x13a
    }

    public var packetLength: Int16 {
        2 + 2
    }

    public var currentAttackRange: Int16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        currentAttackRange = try decoder.decode(Int16.self)
    }
}
