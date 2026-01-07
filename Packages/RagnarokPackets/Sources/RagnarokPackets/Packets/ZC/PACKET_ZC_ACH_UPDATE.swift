//
//  PACKET_ZC_ACH_UPDATE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/28.
//

import BinaryIO

/// See `clif_achievement_update`
public struct PACKET_ZC_ACH_UPDATE: DecodablePacket {
    public var packetType: Int16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)

        // TODO: To be implemented.
        _ = try decoder.decode([UInt8].self, count: 64)
    }
}
