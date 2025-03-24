//
//  PACKET_ZC_COUPLESTATUS.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

import ROCore

/// See `clif_couplestatus`
@available(*, deprecated, message: "Use generated struct instead.")
public struct _PACKET_ZC_COUPLESTATUS: DecodablePacket {
    public static var packetType: Int16 {
        0x141
    }

    public var packetLength: Int16 {
        2 + 4 + 4 + 4
    }

    public var statusType: UInt32
    public var defaultStatus: Int32
    public var plusStatus: Int32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        statusType = try decoder.decode(UInt32.self)
        defaultStatus = try decoder.decode(Int32.self)
        plusStatus = try decoder.decode(Int32.self)
    }
}
