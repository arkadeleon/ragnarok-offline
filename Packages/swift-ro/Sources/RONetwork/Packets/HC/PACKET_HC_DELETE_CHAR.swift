//
//  PACKET_HC_DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

public struct PACKET_HC_DELETE_CHAR: DecodablePacket {
    public static var packetType: UInt16 {
        0x82a
    }

    public var packetLength: UInt16 {
        2 + 4 + 4
    }

    public var aid: UInt32
    public var result: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)
        aid = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
    }
}
