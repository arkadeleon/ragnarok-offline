//
//  PACKET_ZC_EXTEND_BODYITEM_SIZE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

public struct PACKET_ZC_EXTEND_BODYITEM_SIZE: DecodablePacket {
    public static var packetType: UInt16 {
        0xb18
    }

    public var packetLength: UInt16 {
        4
    }

    public var expansionSize: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        expansionSize = try decoder.decode(UInt16.self)
    }
}
