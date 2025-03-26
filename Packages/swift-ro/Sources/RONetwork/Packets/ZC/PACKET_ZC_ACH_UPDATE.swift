//
//  PACKET_ZC_ACH_UPDATE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

/// See `clif_achievement_update`
public struct PACKET_ZC_ACH_UPDATE: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0xa24
    }

    public var packetLength: Int16 {
        2 + 4 + 2 + 4 + 4 + 50
    }

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        // TODO: To be implemented.
        _ = try decoder.decode([UInt8].self, count: 64)
    }
}
