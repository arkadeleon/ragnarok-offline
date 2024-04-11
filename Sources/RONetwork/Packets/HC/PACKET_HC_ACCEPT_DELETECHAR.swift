//
//  PACKET_HC_ACCEPT_DELETECHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

public struct PACKET_HC_ACCEPT_DELETECHAR: DecodablePacket {
    public static var packetType: UInt16 {
        0x6f
    }

    public var packetLength: UInt16 {
        2
    }

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)
    }
}
