//
//  PACKET_ZC_RECOVER_PENALTY_OVERWEIGHT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/3/26.
//

import BinaryIO

public let HEADER_ZC_RECOVER_PENALTY_OVERWEIGHT: Int16 = 0xade

/// See `clif_weight_limit`
public struct PACKET_ZC_RECOVER_PENALTY_OVERWEIGHT: DecodablePacket {
    public var packetType: Int16
    public var percentage: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        percentage = try decoder.decode(UInt32.self)
    }
}
