//
//  PACKET_ZC_LONGPAR_CHANGE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/27.
//

/// See `clif_longpar_change`
public struct PACKET_ZC_LONGPAR_CHANGE: DecodablePacket {
    public static var packetType: Int16 {
        0xb1
    }

    public var packetLength: Int16 {
        2 + 2 + 4
    }

    public var varID: UInt16
    public var amount: Int32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        varID = try decoder.decode(UInt16.self)
        amount = try decoder.decode(Int32.self)
    }
}