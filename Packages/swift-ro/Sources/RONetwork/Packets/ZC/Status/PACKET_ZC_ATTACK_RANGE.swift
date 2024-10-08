//
//  PACKET_ZC_ATTACK_RANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

/// See `clif_attackrange`
public struct PACKET_ZC_ATTACK_RANGE: DecodablePacket {
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
