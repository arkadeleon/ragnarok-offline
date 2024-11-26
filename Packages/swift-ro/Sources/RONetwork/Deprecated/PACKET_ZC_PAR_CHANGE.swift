//
//  PACKET_ZC_PAR_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import ROCore

/// See `clif_par_change`
public struct _PACKET_ZC_PAR_CHANGE: DecodablePacket {
    public static var packetType: Int16 {
        0xb0
    }

    public var packetLength: Int16 {
        2 + 2 + 4
    }

    public var varID: UInt16
    public var count: Int32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        varID = try decoder.decode(UInt16.self)
        count = try decoder.decode(Int32.self)
    }
}
