//
//  PACKET_ZC_STATUS_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

/// See `clif_zc_status_change`
public struct PACKET_ZC_STATUS_CHANGE: DecodablePacket {
    public static var packetType: Int16 {
        0xbe
    }

    public var packetLength: Int16 {
        2 + 2 + 1
    }

    public var statusID: UInt16
    public var value: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        statusID = try decoder.decode(UInt16.self)
        value = try decoder.decode(UInt8.self)
    }
}
