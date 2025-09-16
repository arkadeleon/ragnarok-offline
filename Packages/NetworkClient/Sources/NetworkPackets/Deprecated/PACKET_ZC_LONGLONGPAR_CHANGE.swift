//
//  PACKET_ZC_LONGLONGPAR_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

import BinaryIO

/// See `clif_longlongpar_change`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_LONGLONGPAR_CHANGE: DecodablePacket {
    public static var packetType: Int16 {
        0xacb
    }

    public var packetLength: Int16 {
        2 + 2 + 8
    }

    public var varID: UInt16
    public var amount: Int64

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        varID = try decoder.decode(UInt16.self)
        amount = try decoder.decode(Int64.self)
    }
}
